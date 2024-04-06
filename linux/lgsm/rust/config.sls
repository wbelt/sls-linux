{% if ('rustserver' in pillar) and
      (salt['grains.get']('rustserver:installed', False) == True) %}
{% set user = salt['pillar.get']('rustserver:user','rustserver') %}
{% set userhomedir = '/home/' ~ user %}

rust server cron monitor:
  cron.present:
    - name: "./rustserver monitor > /dev/null 2>&1"
    - identifier: "rustserver monitor"
    - user: {{ user }}
    - minute: "*/5"
    - commented: True

{% if 'rconpassword' in pillar['rustserver'] %}
{% set rconbase = '/usr/local/bin/rcon -t web -a localhost:28016 -p $(cat rconpwd)' %}

rust server hourly time:
  cron.present:
    - name: RCONPWD=$(cat rconpwd); TIME=$(date "+%I:%M %p ET"); echo "say time is ${TIME} password ${RCONPWD}" >> time-reminder.log 2>&1
    - identifier: "hourly time"
    - user: {{ user }}
    - minute: "*/10"

rust server daily reboot 15min:
  cron.present:
    - name: {{ rconbase }} 'say 15 minutes until daily reboot' 2>&1
    - identifier: "daily reboot 15min"
    - user: {{ user }}
    - minute: "30"
    - hour: "4"

rust server daily reboot 10min:
  cron.present:
    - name: {{ rconbase }} 'say 10 minutes until daily reboot' 2>&1
    - identifier: "daily reboot 10min"
    - user: {{ user }}
    - minute: "35"
    - hour: "4"

rust server daily reboot 5min:
  cron.present:
    - name: {{ rconbase }} 'say 5 minutes until daily reboot' 2>&1
    - identifier: "daily reboot 5min"
    - user: {{ user }}
    - minute: "40"
    - hour: "4"

rust server daily reboot 4min:
  cron.present:
    - name: {{ rconbase }} 'say 4 minutes until daily reboot' 2>&1
    - identifier: "daily reboot 4min"
    - user: {{ user }}
    - minute: "41"
    - hour: "4"

rust server daily reboot 3min:
  cron.present:
    - name: {{ rconbase }} 'say 3 minutes until daily reboot' 2>&1
    - identifier: "daily reboot 3min"
    - user: {{ user }}
    - minute: "42"
    - hour: "4"

rust server daily reboot 2min:
  cron.present:
    - name: {{ rconbase }} 'say 2 minutes until daily reboot' 2>&1
    - identifier: "daily reboot 2min"
    - user: {{ user }}
    - minute: "43"
    - hour: "4"

rust server daily reboot 1min:
  cron.present:
    - name: {{ rconbase }} 'say 1 minute until daily reboot' 2>&1
    - identifier: "daily reboot 1min"
    - user: {{ user }}
    - minute: "44"
    - hour: "4"

rust server daily reboot final:
  cron.present:
    - name: {{ rconbase }} 'save' 'quit' >> daily-reboot.log 2>&1
    - identifier: "daily reboot final"
    - user: {{ user }}
    - minute: "45"
    - hour: "4"

rust server daily reboot restart:
  cron.present:
    - name: "./rustserver update-lgsm; ./rustserver update; ./rustserver start"
    - identifier: "daily reboot restart"
    - user: {{ user }}
    - minute: "46"
    - hour: "4"

rust server config update:
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
    - repl: servername="Doom Crickets | Private Server {{ grains['host'] | regex_replace('rs|srv([0-9])', '\\1', ignorecase=True) }}"
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

rust set owners:
  file.managed:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/users.cfg
    - user: {{ user }}
    - group: {{ user }}
    - contents:
{% for owner in salt['pillar.get']('rustserver:owners','') %}
      - ownerid {{ owner }} "unnamed" "no reason"
{% endfor %}

{% endif %}
