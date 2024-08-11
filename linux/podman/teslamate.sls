{% if grains['os_family'] in ['Arch'] %}
{% set user = salt['pillar.get']('teslamate:user','wes') %}
{% set domain = salt['grains.get']('teslamate:domain','none') %}
{% if (salt['grains.get']('teslamate:installed2', False) == False) and
      (domain != 'none') %}

podman server base:
  user.present:
    - name: {{ user }}
    - fullname: Teslamate User
    - shell: /bin/bash
    - createhome: True
  cmd.run:
    - name: "loginctl enable-linger {{ user }}"
  pkg.installed:
    - refresh: True
    - pkgs:
      - podman
      - podman-compose
      - fuse-overlayfs
      - apache

teslamate create podman network:
  cmd.run:
    - name: "podman network create teslamate"
    - runas: {{ user }}

teslamate container directory setup:
  file.directory:
    - name: /home/{{ user }}/.config/containers/systemd
    - mode: "0755"
    - makedirs: true
    - user: {{ user }}

teslamate database container setup:
  file.managed:
    - name: /home/{{ user }}/.config/containers/systemd/teslamate-database.container
    - source: salt://diydev/files/teslamate/teslamate-database.container
    - mode: "0644"
    - user: {{ user }}
    - template: jinja

teslamate grafana container setup:
  file.managed:
    - name: /home/{{ user }}/.config/containers/systemd/teslamate-grafana.container
    - source: salt://diydev/files/teslamate/teslamate-grafana.container
    - mode: "0644"
    - user: {{ user }}
    - template: jinja
    - context:
        dns_domain: {{ domain }}

teslamate app container setup:
  file.managed:
    - name: /home/{{ user }}/.config/containers/systemd/teslamate-teslamate.container
    - source: salt://diydev/files/teslamate/teslamate-teslamate.container
    - mode: "0644"
    - user: {{ user }}
    - template: jinja
    - context:
        dns_domain: {{ domain }}

{% if grains['os_family'] in ['Arch'] %}
  {% set seperator = ':' %}
{% else %}
  {% set seperator = '.' %}
{% endif %}

teslamate set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}{{ seperator }}{{ user }} /home/{{ user }}"

teslamate enable apache:
  cmd.run:
    - name: "systemctl enable --now httpd"

{% set installed = salt['grains.set']('teslamate:installed',True) %}
{% endif %}

teslamate server sudo command local bin:
  file.managed:
    - name: /usr/local/bin/tmsudo
    - source: salt://diydev/files/teslamate/tmsudo
    - mode: "0755"
    - context:
        svcuser: {{ user }}
    - template: jinja

{% set admuser = salt['pillar.get']('adminuser:id',user) %}
teslamate server sudo command home:
  file.managed:
    - name: /home/{{ admuser }}/tmsudo
    - source: salt://diydev/files/teslamate/tmsudo
    - mode: "0744"
    - user: {{ admuser }}
    - group: {{ admuser }}
    - context:
        svcuser: {{ user }}
    - template: jinja

teslamate backup script:
  file.managed:
    - name: /home/{{ user }}/db-backup
    - source: salt://diydev/files/teslamate/teslamate-backup.sh
    - mode: "0744"
    - user: {{ user }}
    - group: {{ user }}
    - template: jinja
teslamate restore script:
  file.managed:
    - name: /home/{{ user }}/db-restore
    - source: salt://diydev/files/teslamate/teslamate-restore.sh
    - mode: "0744"
    - user: {{ user }}
    - group: {{ user }}
    - template: jinja

teslamate apache setup htpasswd:
  file.managed:
    - name: /etc/httpd/conf/htpasswd
    - source: salt://files/teslamate/htpasswd
    - mode: "0644"

teslamate apache setup server.crt teslamate:
  file.managed:
    - name: /etc/httpd/conf/teslamate.{{ domain }}.crt
    - source: salt://files/certs/teslamate.{{ domain }}.crt
    - mode: "0644"

teslamate apache setup server.key teslamate:
  file.managed:
    - name: /etc/httpd/conf/teslamate.{{ domain }}.key
    - source: salt://files/certs/teslamate.{{ domain }}.key
    - mode: "0644"

teslamate apache setup server-ca.crt teslamate:
  file.managed:
    - name: /etc/httpd/conf/teslamate.{{ domain }}.ca-bundle
    - source: salt://files/certs/teslamate.{{ domain }}.ca-bundle
    - mode: "0644"

teslamate apache setup server.crt grafana:
  file.managed:
    - name: /etc/httpd/conf/grafana.{{ domain }}.crt
    - source: salt://files/certs/grafana.{{ domain }}.crt
    - mode: "0644"

teslamate apache setup server.key grafana:
  file.managed:
    - name: /etc/httpd/conf/grafana.{{ domain }}.key
    - source: salt://files/certs/grafana.{{ domain }}.key
    - mode: "0644"

teslamate apache setup server-ca.crt grafana:
  file.managed:
    - name: /etc/httpd/conf/grafana.{{ domain }}.ca-bundle
    - source: salt://files/certs/grafana.{{ domain }}.ca-bundle
    - mode: "0644"

teslamate apache teslamate vhost:
  file.managed:
    - name: /etc/httpd/conf/teslamate.conf
    - source: salt://diydev/files/teslamate/teslamate-apache-vhost.conf
    - mode: "0644"
    - template: jinja
    - context:
        dns_domain: {{ domain }}

teslamate allow conf teslamate:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: ^Include conf/teslamate.conf$
    - repl: 'Include conf/teslamate.conf'
    - count: 1
    - append_if_not_found: true
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

teslamate allow xml2enc_module:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: ^#(LoadModule xml2enc_module.*)$
    - repl: '\1'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

teslamate allow ssl_module:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: ^#(LoadModule ssl_module.*)$
    - repl: '\1'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate allow socache_shmcb_module:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: ^#(LoadModule socache_shmcb_module.*)$
    - repl: '\1'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate allow rewrite_module:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: ^#(LoadModule rewrite_module.*)$
    - repl: '\1'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate allow mod_proxy:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: ^#(LoadModule proxy_module.*)$
    - repl: '\1'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate allow mod_proxy_http:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: ^#(LoadModule proxy_http_module.*)$
    - repl: '\1'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate allow mod_proxy_wstunnel:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: ^#(LoadModule proxy_wstunnel_module.*)$
    - repl: '\1'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate allow ssl extra config:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: ^#(Include conf/extra/httpd-ssl\.conf.*)$
    - repl: '\1'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate disable standard SSLCertificateFile:
  file.replace:
    - name: /etc/httpd/conf/extra/httpd-ssl.conf
    - pattern: ^(S|#S)SLCertificateFile.*$
    - repl: 'SSLCertificateFile /etc/httpd/conf/teslamate.{{ domain }}.crt'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate disable standard SSLCertificateKeyFile:
  file.replace:
    - name: /etc/httpd/conf/extra/httpd-ssl.conf
    - pattern: ^(S|#S)SLCertificateKeyFile.*$
    - repl: 'SSLCertificateKeyFile /etc/httpd/conf/teslamate.{{ domain }}.key'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate disable standard SSLCertificateChainFile:
  file.replace:
    - name: /etc/httpd/conf/extra/httpd-ssl.conf
    - pattern: ^(S|#S)SLCertificateChainFile.*$
    - repl: 'SSLCertificateChainFile /etc/httpd/conf/teslamate.{{ domain }}.ca-bundle'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate disable standard SSLCertificateChainFile:
  file.replace:
    - name: /etc/httpd/conf/extra/httpd-ssl.conf
    - pattern: ^(SSLCertificateChainFile.*)$
    - repl: '#\1'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

{% endif %}
