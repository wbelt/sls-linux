{% if 'rustserver' in pillar %}
{% from './rust_os_map.jinja' import lgsm_os %}
{% include '../init.sls' %}

{{ lgsm_os.defname }} sudo admin command:
  file.managed:
    - name: /usr/local/bin/rssudo
    - source: salt://diydev/files/rust/rssudo
    - mode: "0755"

{{ lgsm_os.defname }} uptime command:
  file.managed:
    - name: /usr/local/bin/rsuptime
    - source: salt://diydev/files/rust/rsuptime
    - mode: "0755"

{{ lgsm_os.defname }} rcon file:
  file.managed:
    - name: /usr/local/bin/rcon
    - source: salt://files/rust/rcon
    - mode: "0755"

{{ lgsm_os.defname }} cron SHELL settings:
  cron.env_present:
    - user: {{ lgsm_os.user }}
    - name: SHELL
    - value: /bin/bash

{{ lgsm_os.defname }} cron PATH settings:
  cron.env_present:
    - user: {{ lgsm_os.user }}
    - name: PATH
    - value: /usr/sbin:/usr/bin:/bin

{{ lgsm_os.defname }}  cron monitor:
  cron.present:
{% if (grains['os'] != 'Ubuntu') or (grains['osrelease_info'][0] != 22 ) %}
    - commented: True
{% else %}
    - commented: False
{% endif %}
    - name: "./rustserver monitor > /dev/null 2>&1"
    - identifier: "rustserver monitor"
    - user: {{ lgsm_os.user }}
    - minute: "*/5"

{% if 'rconpassword' in pillar['rustserver'] %}

{{ lgsm_os.defname }} rconpwd file:
  file.managed:
    - name: {{ lgsm_os.userhomedir }}/rconpwd
    - contents:
      - {{ pillar['rustserver']['rconpassword'] }}
    - user: {{ lgsm_os.user }}
    - group: {{ lgsm_os.user }}
    - mode: "0600"

{{ defname }} maint.conf file:
  file.managed:
    - name: {{ lgsm_os.userhomedir }}/maint.conf
    - source: salt://diydev/files/rust/maint.conf
    - mode: "0600"
    - user: {{ lgsm_os.user }}
    - group: {{ lgsm_os.user }}

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
    - user: {{ lgsm_os.user }}
    - minute: "0"

{{ defname }} daily maintenance:
  cron.present:
    - name: /usr/local/bin/rscon maint >> daily-maint.log 2>&1
    - identifier: "daily maint"
    - user: {{ lgsm_os.user }}
    - hour: "3"

{{ defname }} config update:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/lgsm/config-lgsm/rustserver/secrets-rustserver.cfg
    - append_if_not_found: True
    - pattern: ^rconpassword=.*$
    - repl: rconpassword={{ pillar['rustserver']['rconpassword'] }}
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% endif %}

rust set server description:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.description.*$
    - repl: 'server.description "This is a private server ONLY.\\n"'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set header image:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.headerimage.*$
    - repl: server.headerimage "https://i.imgur.com/uReayFY.jpg"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server URL:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.url.*$
    - repl: server.url "https://twitter.com/DoomCrickets"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server tags:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.tags.*$
    - repl: server.tags "monthly,na,vanilla"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set worldsize:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^worldsize.*$
    - repl: worldsize="4500"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set maxplayers:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^maxplayers.*$
    - repl: maxplayers="50"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server name:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
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
    - name: {{ lgsm_os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^seed=.*$
    - repl: seed="{{ pillar['rustserver']['seeds'][grains['host']] }}"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% else %}
rust remove server seed:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: False
    - pattern: ^seed=.*$
    - repl: ''
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% endif %}

rust set decay:
  file.append:
    - name: {{ lgsm_os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - text: |
        decay.bracket_0_costfraction 0.01
        decay.bracket_1_costfraction 0.015
        decay.bracket_2_costfraction 0.02
        decay.bracket_3_costfraction 0.033

rust set allow minis and motorboats to spawn:
  file.append:
    - name: {{ lgsm_os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - text: |
        minicopter.population 1
        motorrowboat.population 1

rust set to no censor:
  file.replace:
    - name: {{ lgsm_os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.censorplayerlist.*$
    - repl: server.censorplayerlist false
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set owners:
  file.managed:
    - name: {{ lgsm_os.userhomedir }}/serverfiles/server/rustserver/cfg/users.cfg
    - user: {{ lgsm_os.user }}
    - group: {{ lgsm_os.user }}
    - contents:
{% for owner in salt['pillar.get']('rustserver:owners','') %}
      - ownerid {{ owner }} "unnamed" "no reason"
{% endfor %}
{% endif %}
