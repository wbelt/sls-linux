{% if ('rustserver' in pillar) and
      (salt['grains.get']('rustserver:installed', False) == False) %}
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
    - name: /usr/local/bin/rssudo
    - source: salt://files/rssudo
    - mode: "0755"

rust server uptime command:
  file.managed:
    - name: {{ userhomedir }}/rsuptime
    - source: salt://files/rsuptime
    - mode: "0700"
    - user: {{ user }}
    - group: {{ user }}

rust server cron monitor:
  cron.present:
    - name: "./rustserver monitor > /dev/null 2>&1"
    - user: {{ user }}
    - minute: "*/5"

rust server cron update:
  cron.present:
    - name: "./rustserver update >> rs-update.log 2>&1"
    - user: {{ user }}
    - minute: "*/30"

rust server cron update-lgsm:
  cron.present:
    - name: "./rustserver update-lgsm >> lgsm-update.log 2>&1"
    - user: {{ user }}
    - minute: "42"
    - hour: "2"

rust server set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}.{{ user }} /home/{{ user }}"

{% set installed = salt['grains.set']('rustserver:installed',True) %}

{% endif %}
