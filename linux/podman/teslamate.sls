{% if grains['os_family'] in ['Arch'] %}
  {% set install_packages = [ 'podman', 'podman-compose', 'fuse-overlayfs', 'apache' ]  %}
  {% set apache_service = 'httpd' %}
  {% set apache_base = '/etc/' + apache_service %}
  {% set apache_sites = apache_base + '/conf' %}
  {% set key_path = apache_base + '/conf' %}
  {% set cert_path = apache_base + '/conf' %}
  {% set htpasswd_path = apache_sites %}
{% elif grains['os_family'] in ['Debian'] %}
  {% set install_packages = [ 'podman', 'podman-compose', 'apache2', 'systemd-container' ] %}
  {% set apache_service = 'apache2' %}
  {% set apache_base = '/etc/' + apache_service %}
  {% set apache_sites = apache_base + '/sites-available' %}
  {% set key_path = '/etc/ssl/private' %}
  {% set cert_path = '/etc/ssl/certs' %}
  {% set htpasswd_path = apache_sites %}
{% elif grains['os'] == 'Fedora' %}
  {% set install_packages = [ 'podman-compose', 'httpd', 'systemd-container', 'mod_ssl', 'mod_proxy_html', 'patch' ] %}
  {% set apache_service = 'httpd' %}
  {% set apache_base = '/etc/' + apache_service %}
  {% set apache_sites = apache_base + '/conf.d' %}
  {% set key_path = '/etc/pki/tls/private' %}
  {% set cert_path = '/etc/pki/tls/certs' %}
  {% set htpasswd_path = apache_sites %}
  {% set apache_modules_conf = apache_base + '/conf.modules.d' %}
{% endif %}

{% set user = salt['pillar.get']('teslamate:user','wes') %}
{% set domain = salt['pillar.get']('teslamate:domain','none') %}
{% set extra_admin = salt['pillar.get']('teslamate:extra_admin','none') %}

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
    - name: {{ htpasswd_path }}/htpasswd
    - source: salt://files/teslamate/htpasswd
    - mode: "0644"

{% if grains['os_family'] in ['Arch','Debian','RedHat'] %}
  {% set seperator = ':' %}
{% else %}
  {% set seperator = '.' %}
{% endif %}

teslamate set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}{{ seperator }}{{ user }} /home/{{ user }}"

teslamate enable apache:
  cmd.run:
    - name: "systemctl enable {{ apache_service }}"

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
    - name: {{ htpasswd_path }}/htpasswd
    - pattern: ^{{ extra_admin }}$
    - repl: '{{ extra_admin }}'
    - count: 1
    - append_if_not_found: true
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% endif %}

teslamate apache setup server.crt:
  file.managed:
    - name: {{ cert_path }}/tslam8.{{ domain }}.crt
    - source: salt://files/certs/teslamate.{{ domain }}.crt
    - mode: "0644"

teslamate apache setup server.key:
  file.managed:
    - name: {{ key_path }}/tslam8.{{ domain }}.key
    - source: salt://files/certs/teslamate.{{ domain }}.key
{% if grains['os_family'] in ['Debian'] %}
    - group: ssl-cert
{% endif %}
    - mode: "0600"

teslamate apache setup server-ca.crt:
  file.managed:
    - name: {{ cert_path }}/tslam8.{{ domain }}.ca-bundle
    - source: salt://files/certs/teslamate.{{ domain }}.ca-bundle
    - mode: "0600"

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
        htpasswd_path: {{ htpasswd_path }}

{% if grains['os_family'] in ['Debian'] %}
teslamate disable apache default sites:
  cmd.run:
    - name: "a2dissite 000-default default-ssl"
teslamate enable apache modules:
  cmd.run:
    - name: "a2enmod rewrite ssl proxy proxy_http proxy_wstunnel xml2enc"
teslamate apache reload/restart:
  cmd.run:
    - name: "systemctl reload apache2"
{% elif grains['os'] == 'Fedora' %}
{% set rename_module_files = [ '00-brotli.conf','00-proxyhtml.conf','00-lua.conf','00-optional.conf','00-dav.conf','01-cgi.conf','10-proxy_h2.conf','10-h2.conf' ] %}
{% for module in rename_module_files %}
teslamate disable apache module {{ module }}:
  file.rename:
    - source: {{ apache_modules_conf }}/{{ module }}
    - name: {{ apache_modules_conf }}/{{ module }}.bak
{% endfor %}
teslamate patch apache module 00-base.conf:
  file.patch:
    - name: {{ apache_modules_conf }}/00-base.conf
    - source: salt://diydev/files/teslamate/00-base.conf.patch
teslamate patch apache module 00-proxy.conf:
  file.patch:
    - name: {{ apache_modules_conf }}/00-proxy.conf
    - source: salt://diydev/files/teslamate/00-proxy.conf.patch
teslamate replace default SSLCertificateFile:
  file.replace:
    - name: {{ apache_sites }}/ssl.conf
    - pattern: ^(S|#S)SLCertificateFile.*$
    - repl: 'SSLCertificateFile {{ cert_path }}/tslam8.{{ domain }}.crt'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate replace default SSLCertificateKeyFile:
  file.replace:
    - name: {{ apache_sites }}/ssl.conf
    - pattern: ^(S|#S)SLCertificateKeyFile.*$
    - repl: 'SSLCertificateKeyFile {{ key_path }}/tslam8.{{ domain }}.key'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
teslamate replace default SSLCertificateChainFile:
  file.replace:
    - name: {{ apache_sites }}/ssl.conf
    - pattern: ^(S|#S)SLCertificateChainFile.*$
    - repl: 'SSLCertificateChainFile {{cert_path}}/tslam8.{{ domain }}.ca-bundle'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

{% set rename_conf_files = [ 'userdir.conf','welcome.conf' ] %}
{% for site in rename_conf_files %}
teslamate disable apache site {{ site }}:
  file.rename:
    - source: {{ apache_sites }}/{{ site }}
    - name: {{ apache_sites }}/{{ site }}.bak
{% endfor %}

{% endif %}
