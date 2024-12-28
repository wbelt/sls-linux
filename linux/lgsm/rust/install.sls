{% set defname = 'rustserver' %}
{% if 'rustserver' in pillar %}
{% set user = salt['pillar.get'](defname ~ ':user',defname) %}
{% set userhomedir = '/home/' ~ user %}
{% set creates = userhomedir ~ '/serverfiles/server/rustserver/cfg/server.cfg' %}
{% set pkg_base = [ 'bzip2', 'jq', 'lib32gcc-s1', 'lib32stdc++6', 'lib32z1', 'pigz', 'unzip' ] %}
{% if (grains['os'] == 'Ubuntu') and (grains['osrelease_info'][0] == '22') %}
  {% set pkg_extra = [ 'netcat' ] %}
{% else %}
  {% set pkg_extra = [ 'binutils' ] %}
{% endif %}
{% set user_present = [ { 'name': user, 'fullname': 'Rust Server', 'shell': '/bin/bash', 'createhome': True } ] %}
{% set pkg_latest = [ { 'refresh': True, 'pkgs': pkg_base + pkg_extra } ] %}
{% set pkg_i386 = [ 'libsdl2-2.0-0:i386', 'steamcmd' ] %}
{% include '../install.sls' %}
{{ defname }} sudo admin command:
  file.managed:
    - name: /usr/local/bin/rssudo
    - source: salt://diydev/files/rust/rssudo
    - mode: "0755"

{{ defname }} uptime command:
  file.managed:
    - name: /usr/local/bin/rsuptime
    - source: salt://diydev/files/rust/rsuptime
    - mode: "0755"

{{ defname }} rcon file:
  file.managed:
    - name: /usr/local/bin/rcon
    - source: salt://files/rust/rcon
    - mode: "0755"

{% if 'rconpassword' in pillar['rustserver'] %}

{{ defname }} rconpwd file:
  file.managed:
    - name: {{ userhomedir }}/rconpwd
    - contents:
      - {{ pillar['rustserver']['rconpassword'] }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: "0600"

{{ defname }} maint.conf file:
  file.managed:
    - name: {{ userhomedir }}/maint.conf
    - source: salt://diydev/files/rust/maint.conf
    - mode: "0600"
    - user: {{ user }}
    - group: {{ user }}

{{ defname }} rshelper file:
  file.managed:
    - name: /usr/local/bin/rscon
    - source: salt://diydev/files/rust/rscon
    - mode: "0755"

{% endif %}
{% endif %}
