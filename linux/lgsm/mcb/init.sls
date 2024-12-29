{% if grains['os_family'] in ['RedHat'] %}
{% set defname = 'mcbserver' %}
{% set user = salt['pillar.get']('mcbserver:user',defname) %}
{% set userhomedir = '/home/' ~ user %}
{% if salt['grains.get']('mcbserver:installed', False) == False %}
{{ defname }} base:
  pkg.latest:
    - refresh: True
    - pkgs:
      - bc
      - binutils
      - bzip2
      - cpio
      - curl
      - epel-release
      - glibc.i686
      - gzip
      - hostname
      - jq
      - libnsl
      - libstdc++.i686
      - nmap-ncat
      - pigz
      - python3
      - tar
      - tmux
      - unzip
      - util-linux
      - wget
      - xz
      - zlib-devel
  user.present:
    - name: {{ user }}
    - fullname: McB Server
    - shell: /bin/bash
    - createhome: True

{{ defname }} download:
  cmd.run:
    - name: 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh {{ defname }}'
    - runas: {{ user }}
    - creates: {{ userhomedir }}/{{ defname }}

{{ defname }} install:
  cmd.run:
    - name: './{{ defname }} auto-install'
    - runas: {{ user }}
    - creates: {{ userhomedir }}/serverfiles/server.properties

{{ defname }} set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}.{{ user }} /home/{{ user }}"

{% set installed = salt['grains.set']('mcbserver:installed',True) %}
{% endif %}

{{ defname }} mcbcron file:
  file.managed:
    - name: /usr/local/bin/mcbcron
    - source: salt://diydev/files/mcb/mcbcron
    - mode: "0755"

{{ defname }} cron path:
  cron.env_present:
    - name: PATH
    - value: /usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
    - user: {{ user }}

{{ defname }} cron update:
  cron.present:
    - name: /usr/local/bin/mcbcron update >> update.log 2>&1
    - identifier: '{{ defname }} update'
    - user: {{ user }}
    - hour: "3"
    - minute: "15"

{{ defname }} cron reboot:
  cron.present:
    - name: /usr/local/bin/mcbcron reboot >> reboot.log 2>&1
    - identifier: '{{ defname }} reboot'
    - user: {{ user }}
    - hour: "3"
    - minute: "35"

{% endif %}

