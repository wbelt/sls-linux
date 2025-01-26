{% if 'rustserver' in pillar %}
{% from './rust_map.jinja' import lgsm %}
{% include '../init.sls' %}

{{ lgsm.game }} sudo admin command:
  file.managed:
    - name: /usr/local/bin/rssudo
    - source: salt://diydev/files/rust/rssudo
    - mode: "0755"

{{ lgsm.game }} uptime command:
  file.managed:
    - name: /usr/local/bin/rsuptime
    - source: salt://diydev/files/rust/rsuptime
    - mode: "0755"

{{ lgsm.game }} rcon file:
  file.managed:
    - name: /usr/local/bin/rcon
    - source: salt://files/rust/rcon
    - mode: "0755"

{{ lgsm.game }} cron SHELL settings:
  cron.env_present:
    - user: {{ lgsm.os.user }}
    - name: SHELL
    - value: /bin/bash

{{ lgsm.game }} cron PATH settings:
  cron.env_present:
    - user: {{ lgsm.os.user }}
    - name: PATH
    - value: /usr/sbin:/usr/bin:/bin

{{ lgsm.game }}  cron monitor:
  cron.present:
{% if (grains['os'] != 'Ubuntu') or (grains['osrelease_info'][0] != 22 ) %}
    - commented: True
{% else %}
    - commented: False
{% endif %}
    - name: "./rustserver monitor > /dev/null 2>&1"
    - identifier: "rustserver monitor"
    - user: {{ lgsm.os.user }}
    - minute: "*/5"

{% if 'rconpassword' in pillar['rustserver'] %}

{{ lgsm.game }} rconpwd file:
  file.managed:
    - name: {{ lgsm.os.userhomedir }}/rconpwd
    - contents:
      - {{ pillar['rustserver']['rconpassword'] }}
    - user: {{ lgsm.os.user }}
    - group: {{ lgsm.os.user }}
    - mode: "0600"

{{ lgsm.game }} maint.conf file:
  file.managed:
    - name: {{ lgsm.os.userhomedir }}/maint.conf
    - source: salt://diydev/files/rust/maint.conf
    - mode: "0600"
    - user: {{ lgsm.os.user }}
    - group: {{ lgsm.os.user }}

{{ lgsm.game }} rshelper file:
  file.managed:
    - name: /usr/local/bin/rscon
    - source: salt://diydev/files/rust/rscon
    - mode: "0755"

{% set rconbase = 'RCONPWD=$(cat rconpwd); /usr/local/bin/rcon -t web -a localhost:28016 -p $RCONPWD' %}

{{ lgsm.game }} hourly time:
  cron.present:
    - name: /usr/local/bin/rscon saytime >> hourly-time.log 2>&1
    - identifier: "hourly time"
    - user: {{ lgsm.os.user }}
    - minute: "0"

{{ lgsm.game }} daily maintenance:
  cron.present:
    - name: /usr/local/bin/rscon maint >> daily-maint.log 2>&1
    - identifier: "daily maint"
    - user: {{ lgsm.os.user }}
    - hour: "3"

{{ lgsm.game }} config update:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/lgsm/config-lgsm/rustserver/secrets-rustserver.cfg
    - append_if_not_found: True
    - pattern: ^rconpassword=.*$
    - repl: rconpassword={{ pillar['rustserver']['rconpassword'] }}
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% endif %}

rust set server description:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.description.*$
    - repl: 'server.description "This is a private server ONLY.\\n"'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set header image:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.headerimage.*$
    - repl: server.headerimage "https://i.imgur.com/uReayFY.jpg"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server URL:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.url.*$
    - repl: server.url "https://twitter.com/DoomCrickets"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server tags:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.tags.*$
    - repl: server.tags "monthly,na,vanilla"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set worldsize:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^worldsize.*$
    - repl: worldsize="4500"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set maxplayers:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^maxplayers.*$
    - repl: maxplayers="50"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server name:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
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
    - name: {{ lgsm.os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^seed=.*$
    - repl: seed="{{ pillar['rustserver']['seeds'][grains['host']] }}"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% else %}
rust remove server seed:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: False
    - pattern: ^seed=.*$
    - repl: ''
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
{% endif %}

rust set decay:
  file.append:
    - name: {{ lgsm.os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - text: |
        decay.bracket_0_costfraction 0.01
        decay.bracket_1_costfraction 0.015
        decay.bracket_2_costfraction 0.02
        decay.bracket_3_costfraction 0.033

rust set allow minis and motorboats to spawn:
  file.append:
    - name: {{ lgsm.os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - text: |
        minicopter.population 1
        motorrowboat.population 1

rust set to no censor:
  file.replace:
    - name: {{ lgsm.os.userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.censorplayerlist.*$
    - repl: server.censorplayerlist false
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set owners:
  file.managed:
    - name: {{ lgsm.os.userhomedir }}/serverfiles/server/rustserver/cfg/users.cfg
    - user: {{ lgsm.os.user }}
    - group: {{ lgsm.os.user }}
    - contents:
{% for owner in salt['pillar.get']('rustserver:owners','') %}
      - ownerid {{ owner }} "unnamed" "no reason"
{% endfor %}
{% endif %}
