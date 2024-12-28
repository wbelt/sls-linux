{% set defname = 'mcserver' %}
{% set user = salt['pillar.get'](defname ~ ':user',defname) %}
{% set userhomedir = '/home/' ~ user %}
{% set user_present = [ { 'name': user, 'fullname': 'Minecraft Java Server', 'shell': '/bin/bash', 'createhome': True } ] %}
{% set pkg_latest = [ { 'refresh': True, 'pkgs': ['bc', 'binutils', 'bsdmainutils', 'bzip2', 'ca-certificates', 'cpio', 'curl',
  'distro-info', 'file', 'gzip', 'hostname', 'jq', 'lib32gcc-s1', 'lib32stdc++6', 'netcat', 'openjdk-21-jre', 'pigz', 'python3',
  'tar', 'tmux', 'unzip', 'util-linux', 'uuid-runtime', 'wget', 'xz-utils'] } ] %}
{% set creates = userhomedir ~ '/serverfiles/server.properties' %}
{% include '../install.sls' %}

{{ defname }} copy cron script:
  file.managed:
    - name: /usr/local/bin/mccron
    - source: salt://diydev/files/mcserver/mccron
    - mode: "0755"

{{ defname }} set cron path:
  cron.env_present:
    - name: PATH
    - value: /usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
    - user: {{ user }}

{{ defname }} add cron update job:
  cron.present:
    - name: /usr/local/bin/mccron update >> update.log 2>&1
    - identifier: '{{ defname }} update'
    - user: {{ user }}
    - hour: "3"
    - minute: "15"

{{ defname }} add cron reboot job:
  cron.present:
    - name: /usr/local/bin/mccron reboot >> reboot.log 2>&1
    - identifier: '{{ defname }} reboot'
    - user: {{ user }}
    - hour: "3"
    - minute: "35"
    - commented: False
