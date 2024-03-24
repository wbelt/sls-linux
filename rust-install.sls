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
    - pattern: ^rconpassword=.*$
    - repl: rconpassword={{ pillar['rustserver']['rconpassword'] }}
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

rust set server description:
  file.replace:
    - name: /home/{{ pillar['rustserver']['user'] }}/serverfiles/server/rustserver/cfg/server.cfg
    - append_if_not_found: True
    - pattern: ^server.description.*$
    - repl: server.description "Doom Crickets {{ grains['host'] }}"
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

{% endif %}
