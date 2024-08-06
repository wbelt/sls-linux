{% if grains['os_family'] in ['Arch'] %}
{% set user = salt['pillar.get']('teslamate:user','wes') %}

podman server base:
  pkg.installed:
    - refresh: True
    - pkgs:
      - podman
      - podman-compose
      - fuse-overlayfs
      - apache
  user.present:
    - name: {{ user }}
    - fullname: Teslamate User
    - shell: /bin/bash
    - createhome: True
    - groups:
      - wheel

teslamate podman copy:
  file.managed:
    - name: /home/{{ user }}/{{ upname }}
    - source: salt://files/teslamate/{{ upname }}
    - mode: "0644"
    - user: {{ user }}

teslamate update podman version:
  cmd.run:
    - name: "pacman --noconfirm -U /home/{{ user }}/{{ upname }}"

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

teslamate app container setup:
  file.managed:
    - name: /home/{{ user }}/.config/containers/systemd/teslamate-teslamate.container
    - source: salt://diydev/files/teslamate/teslamate-teslamate.container
    - mode: "0644"
    - user: {{ user }}
    - template: jinja

teslamate apache setup htpasswd:
  file.managed:
    - name: /etc/httpd/conf/htpasswd
    - source: salt://files/teslamate/htpasswd
    - mode: "0644"

teslamate apache setup server.crt:
  file.managed:
    - name: /etc/httpd/conf/server.crt
    - source: salt://files/certs/splat.flbelt.com.crt
    - mode: "0644"

teslamate apache setup server.key:
  file.managed:
    - name: /etc/httpd/conf/server.key
    - source: salt://files/certs/splat.flbelt.com.key
    - mode: "0644"

teslamate apache setup server-ca.crt:
  file.managed:
    - name: /etc/httpd/conf/server-ca.crt
    - source: salt://files/certs/splat.flbelt.com.ca-bundle
    - mode: "0644"

teslamate apache teslamate vhost:
  file.managed:
    - name: /etc/httpd/conf/teslamate.conf
    - source: salt://diydev/files/teslamate/teslamate-apache-vhost.conf
    - mode: "0644"

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

{% if grains['os_family'] in ['Arch'] %}
  {% set seperator = ':' %}
{% else %}
  {% set seperator = '.' %}
{% endif %}

teslamate set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}{{ seperator }}{{ user }} /home/{{ user }}"

teslamate systemd generator:
  cmd.run:
    - name: "systemctl --user daemon-reload"
    - user: {{ user }}

teslamate enable apache:
  cmd.run:
    - name: "systemctl enable --now httpd"

{% endif %}
