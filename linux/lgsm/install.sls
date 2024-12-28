include:
  - .bootstrap

lgsm {{ defname }} auto-install:
  cmd.run:
    - name: './{{ defname }} auto-install'
    - runas: {{ user }}

lgsm {{ defname }} set homedir owner:
  cmd.run:
    - name: "chown -R {{ user }}:{{ user }} /home/{{ user }}"
