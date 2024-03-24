{% if 'rustserver' in pillar %}
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
    - name: {{ pillar['rustserver']['user'] }}
    - fullname: Rust Server
    - shell: /bin/bash
    - createhome: True

rust server download:
  cmd.run:
    - name: 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh rustserver'
    - runas: {{ pillar['rustserver']['user'] }}
    - creates: /home/{{ pillar['rustserver']['user'] }}/rustserver

rust server install:
  cmd.run:
    - name: './rustserver auto-install'
    - runas: rustserver
    - creates: /home/{{ pillar['rustserver']['user'] }}/serverfiles/server/rustserver/cfg/server.cfg

rust server config update:
  file.replace:
    - name: /home/{{ pillar['rustserver']['user'] }}/lgsm/config-lgsm/rustserver/secrets-rustserver.cfg
    - append_if_not_found: True
    - pattern: ^rconpassword=\.*$
    - repl: rconpassword={{ pillar['rustserver']['rconpassword'] }}
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server description:
  file.replace:
    - name: /home/{{ pillar['rustserver']['user'] }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.description.*$
    - repl: server.description "This is a private server ONLY. Blueprints wipe only when forced by Facepunch. Decay is 10% of normal and minis spawn on roads and motorboats spawn on coasts."
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set header image:
  file.replace:
    - name: /home/{{ pillar['rustserver']['user'] }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.headerimage.*$
    - repl: server.headerimage "https://i.imgur.com/uReayFY.jpg"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server URL:
  file.replace:
    - name: /home/{{ pillar['rustserver']['user'] }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.url.*$
    - repl: server.url "https://twitter.com/DoomCrickets"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server tags:
  file.replace:
    - name: /home/{{ pillar['rustserver']['user'] }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server\.tags.*$
    - repl: server.tags "monthly,na,vanilla"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set worldsize:
  file.replace:
    - name: /home/{{ pillar['rustserver']['user'] }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^worldsize.*$
    - repl: worldsize="4500"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set maxplayers:
  file.replace:
    - name: /home/{{ pillar['rustserver']['user'] }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^maxplayers.*$
    - repl: maxplayers="55"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server name:
  file.replace:
    - name: /home/{{ pillar['rustserver']['user'] }}/lgsm/config-lgsm/rustserver/rustserver.cfg
    - append_if_not_found: True
    - pattern: ^servername.*$
    - repl: servername="Doom Crickets | Private Server {{ grains['host'] }}"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

{% if 'owners' in pillar['rustserver'] %}
{% for owner in pillar['rustserver']['owners'] %}
rust set owner {{owner}}:
  file.append:
    - name: /home/{{ pillar['rustserver']['user'] }}/serverfiles/server/rustserver/cfg/users.cfg
    - text: 'ownerid {{ owner }}'
{% endfor %}
{% endif %}

{% endif %}
