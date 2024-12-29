{% set defname = 'rustserver' %}
{% if 'rustserver' in pillar %}
{% set user = salt['pillar.get'](defname ~ ':user',defname) %}
{% set userhomedir = '/home/' ~ user %}
{% set creates = userhomedir ~ '/serverfiles/server/rustserver/cfg/server.cfg' %}
{% set pkg_base = [ 'bzip2', 'jq', 'lib32gcc-s1', 'lib32stdc++6', 'lib32z1', 'pigz', 'unzip' ] %}
{% if (grains['os'] == 'Ubuntu') and (grains['osrelease_info'][0] == 22 ) %}
  {% set pkg_extra = [ 'netcat' ] %}
{% else %}
  {% set pkg_extra = [ 'binutils' ] %}
{% endif %}
{% set user_present = [ { 'name': user, 'fullname': 'Rust Server', 'shell': '/bin/bash', 'createhome': True } ] %}
{% set pkg_latest = [ { 'refresh': True, 'pkgs': pkg_base + pkg_extra } ] %}
{% set pkg_i386 = [ 'libsdl2-2.0-0:i386', 'steamcmd' ] %}
{% include '../init.sls' %}
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

{{ defname }} cron SHELL settings:
  cron.env_present:
    - user: {{ user }}
    - name: SHELL
    - value: /bin/bash

{{ defname }} cron PATH settings:
  cron.env_present:
    - user: {{ user }}
    - name: PATH
    - value: /usr/sbin:/usr/bin:/bin

{{ defname }}  cron monitor:
  cron.present:
{% if (grains['os'] != 'Ubuntu') or (grains['osrelease_info'][0] != 22 ) %}
    - commented: True
{% else %}
    - commented: False
{% endif %}
    - name: "./rustserver monitor > /dev/null 2>&1"
    - identifier: "rustserver monitor"
    - user: {{ user }}
    - minute: "*/5"

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

{% set rconbase = 'RCONPWD=$(cat rconpwd); /usr/local/bin/rcon -t web -a localhost:28016 -p $RCONPWD' %}

{{ defname }} hourly time:
  cron.present:
    - name: /usr/local/bin/rscon saytime >> hourly-time.log 2>&1
    - identifier: "hourly time"
    - user: {{ user }}
    - minute: "0"

{{ defname }} daily maintenance:
  cron.present:
    - name: /usr/local/bin/rscon maint >> daily-maint.log 2>&1
    - identifier: "daily maint"
    - user: {{ user }}
    - hour: "3"

{{ defname }} config update:
  file.replace:
    - name: {{ userhomedir }}/lgsm/config-lgsm/rustserver/secrets-rustserver.cfg
    - append_if_not_found: True
    - pattern: ^rconpassword=.*$
    - repl: rconpassword={{ pillar['rustserver']['rconpassword'] }}
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% endif %}

rust set server description:
  file.replace:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.description.*$
    - repl: 'server.description "This
        is a private server ONLY.\\nBlueprints wipe only when forced
        by Facepunch.\\nDecay is 10% of normal and minis spawn
        on roads and motorboats spawn on coasts."'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set header image:
  file.replace:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.headerimage.*$
    - repl: server.headerimage "https://i.imgur.com/uReayFY.jpg"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server URL:
  file.replace:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.url.*$
    - repl: server.url "https://twitter.com/DoomCrickets"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server tags:
  file.replace:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.tags.*$
    - repl: server.tags "monthly,na,vanilla"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set worldsize:
  file.replace:
    - name: {{ userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^worldsize.*$
    - repl: worldsize="4500"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set maxplayers:
  file.replace:
    - name: {{ userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^maxplayers.*$
    - repl: maxplayers="50"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server name:
  file.replace:
    - name: {{ userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^servername.*$
    - repl: servername="Doom Crickets | Private Server {{ grains['host'] | regex_replace('lgsm([0-9])', '\\1', ignorecase=True) }}"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

{% if ('seeds' in pillar['rustserver']) and
      (grains['host'] in pillar['rustserver']['seeds']) %}
rust set server seed:
  file.replace:
    - name: {{ userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^seed=.*$
    - repl: seed="{{ pillar['rustserver']['seeds'][grains['host']] }}"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% else %}
rust remove server seed:
  file.replace:
    - name: {{ userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: False
    - pattern: ^seed=.*$
    - repl: ''
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% endif %}

rust set decay:
  file.append:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - text: |
        decay.bracket_0_costfraction 0.01
        decay.bracket_1_costfraction 0.015
        decay.bracket_2_costfraction 0.02
        decay.bracket_3_costfraction 0.033

rust set allow minis and motorboats to spawn:
  file.append:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - text: |
        minicopter.population 1
        motorrowboat.population 1

rust set to no censor:
  file.replace:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.censorplayerlist.*$
    - repl: server.censorplayerlist false
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set owners:
  file.managed:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/users.cfg
    - user: {{ user }}
    - group: {{ user }}
    - contents:
{% for owner in salt['pillar.get']('rustserver:owners','') %}
      - 'ownerid {{ owner }} "unnamed" "no reason" '
{% endfor %}

{% endif %}
