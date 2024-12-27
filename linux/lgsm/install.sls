{% set user = salt['pillar.get'](defname ~ ':user',defname) %}
{% set userhomedir = '/home/' ~ user %}
{{ defname }} install:
  cmd.run:
    - name: './{{ defname }} auto-install'
    - runas: {{ user }}
    - creates: {{ userhomedir }}/serverfiles/server.properties

{{ defname }} set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}:{{ user }} /home/{{ user }}"

