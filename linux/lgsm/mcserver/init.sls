
{% from './mcserver_map.jinja' import lgsm %}
{% include '../init.sls' %}

{{ lgsm.game }} copy cron script:
  file.managed:
    - name: /usr/local/bin/mccron
    - source: salt://diydev/files/mcserver/mccron
    - mode: "0755"

{{ lgsm.game }} set cron path:
  cron.env_present:
    - name: PATH
    - value: /usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
    - user: {{ lgsm.os.user }}

{{ lgsm.game }} add cron update job:
  cron.present:
    - name: /usr/local/bin/mccron update >> update.log 2>&1
    - identifier: '{{ defname }} update'
    - user: {{ lgsm.os.user }}
    - hour: "3"
    - minute: "15"

{{ lgsm.game }} add cron reboot job:
  cron.present:
    - name: /usr/local/bin/mccron reboot >> reboot.log 2>&1
    - identifier: '{{ defname }} reboot'
    - user: {{ lgsm.os.user }}
    - hour: "3"
    - minute: "35"
    - commented: False
