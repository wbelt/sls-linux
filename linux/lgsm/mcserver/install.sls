{% set defname = 'mcserver' %}
{% set user = salt['pillar.get'](defname ~ ':user',defname) %}
{% set userhomedir = '/home/' ~ user %}
{% if salt['grains.get'](defname ~ ':installed', False) == False %}
{{ defname }} base:
  pkg.latest:
    - refresh: True
    - pkgs:
      - bc
      - binutils
      - bsdmainutils
      - bzip2
      - ca-certificates
      - cpio
      - curl
      - distro-info
      - file
      - gzip
      - hostname
      - jq
      - lib32gcc-s1
      - lib32stdc++6
      - netcat
      - openjdk-21-jre
      - pigz
      - python3
      - tar
      - tmux
      - unzip
      - util-linux
      - uuid-runtime
      - wget
      - xz-utils
  user.present:
    - name: {{ user }}
    - fullname: Minecraft Java Server
    - shell: /bin/bash
    - createhome: True

include:
  - ...install.sls
{% set installed = salt['grains.set'](defname ~ ':installed',True) %}
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
    - commented: True

{{ defname }} cron reboot:
  cron.present:
    - name: /usr/local/bin/mcbcron reboot >> reboot.log 2>&1
    - identifier: '{{ defname }} reboot'
    - user: {{ user }}
    - hour: "3"
    - minute: "35"
    - commented: True
