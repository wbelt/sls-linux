{% if defname %}
{% if pkg.latest %}
lgsm {{ defname }} package install:
  pkg.latest: {{ pkg.latest }}
{% endif %}

{% if user.present %}
lgsm {{ defname }} user creation:
  user.present: {{ user.present }}
{% endif %}

lgsm {{ defname }} download:
  cmd.run:
    - name: 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh {{ defname }}'
    - runas: {{ user }}
    - creates: {{ userhomedir }}/{{ defname }}

lgsm {{ defname }} auto-install:
  cmd.run:
    - name: './{{ defname }} auto-install'
    - runas: {{ user }}
{% if creates %}
    - creates: {{ creates }}
{% endif %}

lgsm {{ defname }} set homedir owner:
  cmd.run:
    - name: "echo $(date) > /home/{{ user }}/.completed-set-owner.flag && chown -R {{ user }}:{{ user }} /home/{{ user }}"
    - creates: /home/{{ user }}/.completed-set-owner.flag
{% endif %}
