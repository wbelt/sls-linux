{% if 'rustserver' in pillar %}
{% set user = salt['pillar.get']('rustserver:user','rustserver') %}
{% set userhomedir = '/home/' ~ user %}
rust server base:
  pkg.latest:
    - refresh: True
    - pkgs:
      - bc
      - binutils
      - bzip2
      - epel-release
      - glibc.i686
      - jq
      - libstdc++.i686
      - nmap-ncat
      - python3
      - tmux
      - unzip
      - zlib-devel
  user.present:
    - name: {{ user }}
    - fullname: Rust Server
    - shell: /bin/bash
    - createhome: True

rust server download:
  cmd.run:
    - name: 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh rustserver'
    - runas: {{ user }}
    - creates: {{ userhomedir }}/rustserver

rust server install:
  cmd.run:
    - name: './rustserver auto-install'
    - runas: {{ user }}
    - creates: {{ userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg

rust server sudo admin command:
  file.managed:
    - name: /usr/local/bin/sudors
    - source: salt://files/sudors
    - mode: "0755"

rust server config update:
  file.replace:
    - name: {{ userhomedir }}/lgsm/config-lgsm/rustserver/secrets-rustserver.cfg
    - append_if_not_found: True
    - pattern: ^rconpassword=.*$
    - repl: rconpassword={{ salt['pillar.get']('rustserver:rconpassword','LegoLAND$8973') }}
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server description:
  file.replace:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.description.*$
    - repl: 'server.description
        "This is a private server ONLY.\\n\
        Blueprints wipe only when forced by Facepunch.\\n\
        Decay is 10% of normal and minis spawn on roads and motorboats spawn on coasts."
        '
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
    - repl: maxplayers="55"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server name:
  file.replace:
    - name: {{ userhomedir }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^servername.*$
    - repl: servername="Doom Crickets | Private Server {{ grains['host'] }}"
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

{% for owner in salt['pillar.get']('rustserver:owners','') %}
rust set owner {{ owner }}:
  file.append:
    - name: {{ userhomedir }}/serverfiles/server/rustserver/cfg/users.cfg
    - text: 'ownerid {{ owner }} "unnamed" "no reason"'
{% endfor %}

rust server cron monitor:
  cron.present:
    - name: "./rustserver monitor > /dev/null 2>&1"
    - user: {{ user }}
    - minute: "*/5"

rust server cron update:
  cron.present:
    - name: "./rustserver update > /dev/null 2>&1"
    - user: {{ user }}
    - minute: "*/30"

rust server cron update-lgsm:
  cron.present:
    - name: "./rustserver update-lgsm > /dev/null 2>&1"
    - user: {{ user }}
    - minute: "42"
    - hour: "2"

#rust server set homedir owner:
#  cmd.run:
#    - name: "chown -R {{ user }}.{{ user }} /home/{{ user }}"

{% endif %}
