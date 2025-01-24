{% if lgsm.defname is defined %}

lgsm {{ lgsm.defname }} package install:
  pkg.latest: [ { refresh: True, pkgs: {{ lgsm.packages.common + lgsm.packages.latest }} } ]

{% if grains['os'] == 'Ubuntu' %}
lgsm {{ lgsm.defname }} debconf set:
  debconf.set:
    - name: dash
    - data:
        steam/question: {'type': 'select', 'value': 'I AGREE'}
        steam/license: {'type': 'note', 'value': ''}

{% if lgsm.packages.i386 is defined %}
lgsm {{ lgsm.defname }} i386 install:
  cmd.run:
    - name: 'dpkg --add-architecture i386; apt update; DEBIAN_FRONTEND=noninteractive apt install --yes {{ lgsm.packages.i386 | join(" ") }}'
    - creates: /usr/games/steamcmd
{% endif %}
{% endif %}

lgsm {{ lgsm.defname }} user creation:
  user.present: [ {{ lgsm.user_present }} ]

lgsm {{ lgsm.defname }} download:
  cmd.run:
    - name: 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh {{ lgsm.defname }}'
    - runas: {{ lgsm.user }}
    - creates: {{ lgsm.userhomedir }}/{{ lgsm.defname }}

lgsm {{ lgsm.defname }} auto-install:
  cmd.run:
    - name: './{{ lgsm.defname }} auto-install'
    - runas: {{ lgsm.user }}
{% if lgsm.creates %}
    - creates: {{ lgsm.creates }}
{% endif %}

lgsm {{ lgsm.defname }} set homedir owner:
  cmd.run:
    - name: "echo $(date) > /home/{{ lgsm.user }}/.completed-set-owner.flag && chown -R {{ lgsm.user }}:{{ lgsm.user }} /home/{{ lgsm.user }}"
    - creates: /home/{{ lgsm.user }}/.completed-set-owner.flag
{% endif %}
