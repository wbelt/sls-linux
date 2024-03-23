{% import_yaml 'settings/rustserver.yaml' as rs %}

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
    - name: {{ rs['user'] }}
    - fullname: Rust Server
    - shell: /bin/bash
    - createhome: True

rust server download:
  cmd.run:
    - name: 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh rustserver'
    - runas: {{ rs['user'] }}
    - creates: /home/{{ rs['user'] }}/rustserver

rust server install:
  cmd.run:
    - name: './rustserver auto-install'
    - runas: rustserver
    - creates: /home/{{ rs['user'] }}/serverfiles/server/rustserver/cfg/server.cfg
  file.replace:
    - name: /home/{{ rs['user'] }}/lgsm/config-lgsm/rustserver/secrets-rustserver.cfg
    - append_if_not_found: True
    - pattern: ^rconpassword=.*$
    - repl: rconpassword={{ rs['rconpassword'] }}
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']