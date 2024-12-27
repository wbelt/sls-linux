{% set mod_desc = 'scp-utils' %}
{% set mytu_user = 'mytu' %}
{{ mod_desc }} base user:
  user.present:
    - name: {{ mytu_user }}
    - fullname: My Transfer Utility
    - shell: /bin/bash
    - createhome: True
  cmd.run:
    - name: ssh-keygen -t ed25519 -q -N '' -t ed25519 -f /home/{{ mytu_user }}/.ssh/id_ed25519
    - runas: {{ mytu_user }}
    - creates: /home/{{ mytu_user}}/.ssh/id_ed25519
  file.copy:
    - name: /etc/{{ mytu_user}}.key
    - mode: "0755"
    - source: /home/{{ mytu_user}}/.ssh/id_ed25519

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
