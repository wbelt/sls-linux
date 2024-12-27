{% set mod_desc = 'scp-utils' %}
{{ mod_desc }} copy scp-get:
  file.managed:
    - name: /usr/local/bin/scp-get
    - source: salt://diydev/files/salt/minion/scp-get
    - mode: "0755"

{{ mod_desc }} copy scp-put:
  file.managed:
    - name: /usr/local/bin/scp-put
    - source: salt://diydev/files/salt/minion/scp-put
    - mode: "0755"
