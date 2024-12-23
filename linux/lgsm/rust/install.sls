{% if ('rustserver' in pillar) %}
{% if (salt['grains.get']('rustserver:installed2', False) == False) %}
{% set user = salt['pillar.get']('rustserver:user','rustserver') %}
{% set userhomedir = '/home/' ~ user %}

debconf-base:
  debconf.set:
    - name: dash
    - data:
        steam/question: {'type': 'select', 'value': 'I AGREE'}
        steam/license: {'type': 'note', 'value': ''}

rust server base:
  user.present:
    - name: {{ user }}
    - fullname: Rust Server
    - shell: /bin/bash
    - createhome: True
  pkg.latest:
    - pkgs:
      - bzip2
      - jq
      - lib32gcc-s1
      - lib32stdc++6
      - lib32z1
      - netcat
      - pigz
      - unzip
  cmd.run:
    - name: 'dpkg --add-architecture i386; apt update; apt install --yes libsdl2-2.0-0:i386 steamcmd'
    - onchanges:
      - debconf: debconf-base

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
    - source: salt://diydev/files/rust/rssudo
    - mode: "0755"

rust server uptime command:
  file.managed:
    - name: /usr/local/bin/rsuptime
    - source: salt://diydev/files/rust/rsuptime
    - mode: "0755"

rust server rcon file:
  file.managed:
    - name: /usr/local/bin/rcon
    - source: salt://files/rust/rcon
    - mode: "0755"

{% if 'rconpassword' in pillar['rustserver'] %}

rust server rconpwd file:
  file.managed:
    - name: {{ userhomedir }}/rconpwd
    - contents:
      - {{ pillar['rustserver']['rconpassword'] }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: "0600"

rust server maint.conf file:
  file.managed:
    - name: {{ userhomedir }}/maint.conf
    - source: salt://diydev/files/rust/maint.conf
    - mode: "0600"
    - user: {{ user }}
    - group: {{ user }}

rust server rshelper file:
  file.managed:
    - name: /usr/local/bin/rscon
    - source: salt://diydev/files/rust/rscon
    - mode: "0755"

{% endif %}

rust server set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}.{{ user }} /home/{{ user }}"

{% set installed = salt['grains.set']('rustserver:installed',True) %}

{% endif %}
{% endif %}
