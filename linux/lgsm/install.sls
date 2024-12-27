{{ defname }} install:
  cmd.run:
    - name: './{{ defname }} auto-install'
    - runas: {{ user }}

{{ defname }} set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}:{{ user }} /home/{{ user }}"
