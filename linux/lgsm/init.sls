{% if defname is defined %}
lgsm {{ defname }} package install:
  pkg.latest: [ { refresh: True, pkgs: {{ pkg_latest }} } ]

{% if grains['os'] == 'Ubuntu' %}
lgsm {{ defname }} debconf set:
  debconf.set:
    - name: dash
    - data:
        steam/question: {'type': 'select', 'value': 'I AGREE'}
        steam/license: {'type': 'note', 'value': ''}
{% if pkg_i386 is defined %}
lgsm {{ defname }} i386 install:
  cmd.run:
    - name: 'dpkg --add-architecture i386; apt update; DEBIAN_FRONTEND=noninteractive apt install --yes {{ pkg_i386 | join(" ") }}'
    - creates: /usr/games/steamcmd
{% endif %}
{% endif %}

lgsm {{ defname }} user creation:
  user.present: {{ user_present }}

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
