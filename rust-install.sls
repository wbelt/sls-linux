{% set rustuser = 'rustserver' %}
{% set rconpwd = 'salt://settings/rconpwd.conf' %}

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
    - name: {{ rustuser }}
    - fullname: Rust Server
    - shell: /bin/bash
    - createhome: True

rust server download:
  cmd.run:
    - name: 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh rustserver'
    - runas: {{ rustuser }}
    - creates: /home/{{ rustuser }}/rustserver

rust server install:
  cmd.run:
    - name: './rustserver auto-install'
    - runas: rustserver
    - creates: /home/{{ rustuser }}/serverfiles/server/rustserver/cfg/server.cfg
  file.replace:
    - name: /home/{{ rustuser }}/lgsm/config-lgsm/rustserver/secrets-rustserver.cfg
    - append_if_not_found: True
    - pattern: ^rconpassword=.*$
    - repl: {{ rcondpwd }}
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']