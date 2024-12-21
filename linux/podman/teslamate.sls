{% if grains['os_family'] in ['Arch'] %}
  {% set install_packages = [ 'podman', 'podman-compose', 'fuse-overlayfs', 'apache' ]  %}
  {% set apache_service = 'httpd' %}
  {% set apache_base = '/etc/' + apache_service %}
  {% set apache_sites = apache_base + '/conf' %}
  {% set key_path = apache_base + '/conf' %}
  {% set cert_path = apache_base + '/conf' %}
  /etc/httpd/conf
{% elif grains['os_family'] in ['Debian'] %}
  {% set install_packages = [ 'podman', 'podman-compose', 'apache2' ] %}
  {% set apache_service = 'apache2' %}
  {% set apache_base = '/etc/' + apache_service %}
  {% set apache_sites = apache_base + '/sites-available' %}
  {% set key_path = '/etc/ssl/private' %}
  {% set cert_path = '/etc/ssl/certs' %}
{% endif %}

{% set user = salt['pillar.get']('teslamate:user','wes') %}
{% set domain = salt['grains.get']('teslamate:domain','none') %}
{% set extra_admin = salt['grains.get']('teslamate:extra_admin','none') %}

{% if (salt['grains.get']('teslamate:installed', False) == False) and
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
    - pkgs: {{ install_packages }}

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

teslamate apache setup htpasswd:
  file.managed:
    - name: {{ apache_base }}/htpasswd
    - source: salt://files/teslamate/htpasswd
    - mode: "0644"

{% if grains['os_family'] in ['Arch','Debian'] %}
  {% set seperator = ':' %}
{% else %}
  {% set seperator = '.' %}
{% endif %}

teslamate set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}{{ seperator }}{{ user }} /home/{{ user }}"

teslamate enable apache:
  cmd.run:
    - name: "systemctl enable --now {{ apache_service }}"

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

{% if extra_admin != 'none' %}
teslamate apache setup htpasswd extra admin:
  file.replace:
    - name: {{ apache_base }}/htpasswd
    - pattern: ^{{ extra_admin }}$
    - repl: '{{ extra_admin }}'
    - count: 1
    - append_if_not_found: true
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% endif %}

teslamate apache setup server.crt teslamate:
  file.managed:
    - name: {{ cert_path }}/teslamate.{{ domain }}.crt
    - source: salt://files/certs/teslamate.{{ domain }}.crt
    - mode: "0644"

teslamate apache setup server.key teslamate:
  file.managed:
    - name: {{ key_path }}/teslamate.{{ domain }}.key
    - source: salt://files/certs/teslamate.{{ domain }}.key
    - mode: "0644"

teslamate apache setup server-ca.crt teslamate:
  file.managed:
    - name: {{ cert_path }}/teslamate.{{ domain }}.ca-bundle
    - source: salt://files/certs/teslamate.{{ domain }}.ca-bundle
    - mode: "0644"

teslamate apache setup server.crt grafana:
  file.managed:
    - name: {{ cert_path }}/grafana.{{ domain }}.crt
    - source: salt://files/certs/grafana.{{ domain }}.crt
    - mode: "0644"

teslamate apache setup server.key grafana:
  file.managed:
    - name: {{ key_path }}/grafana.{{ domain }}.key
    - source: salt://files/certs/grafana.{{ domain }}.key
    - mode: "0644"

teslamate apache setup server-ca.crt grafana:
  file.managed:
    - name: {{ cert_path }}/grafana.{{ domain }}.ca-bundle
    - source: salt://files/certs/grafana.{{ domain }}.ca-bundle
    - mode: "0644"

teslamate apache teslamate vhost:
  file.managed:
    - name: {{ apache_sites }}/teslamate.conf
    - source: salt://diydev/files/teslamate/teslamate-apache-vhost.conf
    - mode: "0644"
    - template: jinja
    - context:
        dns_domain: {{ domain }}
        log_path: /var/log/{{ apache_service }}
        key_path: {{ key_path }}
        cert_path: {{ cert_path }}