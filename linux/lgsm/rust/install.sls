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
    - identifier: "rustserver monitor"
    - user: {{ user }}
    - minute: "*/5"

{% if 'rconpassword' in pillar['rustserver'] %}
rust server daily reboot 2min:
  cron.present:
    - name: './rcon-0.10.3-amd64_linux/rcon -t web -a localhost:28016 -p {{ pillar['rustserver']['rconpassword'] }} "say 2 minutes until daily reboot" 2>&1'
    - identifier: "daily reboot 2min"
    - user: {{ user }}
    - minute: "43"
    - hour: "4"

  cron.present:
    - name: './rcon-0.10.3-amd64_linux/rcon -t web -a localhost:28016 -p {{ pillar['rustserver']['rconpassword'] }} "say 1 minute until daily reboot" 2>&1'
    - identifier: "daily reboot 1min"
    - user: {{ user }}
    - minute: "44"
    - hour: "4"

rust server daily reboot final:
  cron.present:
    - name: "./rcon-0.10.3-amd64_linux/rcon -t web -a localhost:28016 -p {{ pillar['rustserver']['rconpassword'] }} quit >> daily-reboot.log 2>&1"
    - identifier: "daily reboot final"
    - user: {{ user }}
    - minute: "45"
    - hour: "4"

rust server daily reboot restart:
  cron.present:
    - name: "./rustserver update-lgsm && ./rustserver update && ./rustserver start"
    - identifier: "daily reboot restart"
    - user: {{ user }}
    - minute: "46"
    - hour: "4"
{% endif %}

rust server set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}.{{ user }} /home/{{ user }}"

{% set installed = salt['grains.set']('rustserver:installed',True) %}

{% endif %}
