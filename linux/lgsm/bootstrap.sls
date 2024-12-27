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
    - name: "chown -R {{ user }}:{{ user }} /home/{{ user }}"

