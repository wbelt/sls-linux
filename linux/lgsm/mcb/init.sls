{% from './mcbserver_map.jinja' import lgsm %}
{% include '../init.sls' %}

{{ lgsm.game }} mcbcron file:
  file.managed:
    - name: /usr/local/bin/mcbcron
    - source: salt://diydev/files/mcb/mcbcron
    - mode: "0755"

{{ lgsm.game }} cron path:
  cron.env_present:
    - name: PATH
    - value: /usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
    - user: {{ lgsm.os.user }}

{{ lgsm.game }} cron update:
  cron.present:
    - name: /usr/local/bin/mcbcron update >> update.log 2>&1
    - identifier: '{{ lgsm.game }} update'
    - user: {{ lgsm.os.user }}
    - hour: "3"
    - minute: "15"

{{ lgsm.game }} cron reboot:
  cron.present:
    - name: /usr/local/bin/mcbcron reboot >> reboot.log 2>&1
    - identifier: '{{ lgsm.game }} reboot'
    - user: {{ lgsm.os.user }}
    - hour: "3"
    - minute: "35"
