{% if lgsm.app is defined %}

lgsm {{ lgsm.app }} package install:
  pkg.latest: [ { refresh: True, pkgs: {{ lgsm.packages.common + lgsm.packages.latest }} } ]

{% if grains['os'] == 'Ubuntu' %}
lgsm {{ lgsm.app }} debconf set:
  debconf.set:
    - name: dash
    - data:
        steam/question: {'type': 'select', 'value': 'I AGREE'}
        steam/license: {'type': 'note', 'value': ''}

{% if lgsm.packages.i386 is defined %}
lgsm {{ lgsm.app }} i386 install:
  cmd.run:
    - name: 'dpkg --add-architecture i386; apt update; DEBIAN_FRONTEND=noninteractive apt install --yes {{ lgsm.packages.i386 | join(" ") }}'
    - creates: /usr/games/steamcmd
{% endif %}
{% endif %}

lgsm {{ lgsm.app }} user creation:
  user.present: [ {{ lgsm.os.user_present }} ]

lgsm {{ lgsm.app }} download:
  cmd.run:
    - name: 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh {{ lgsm.app }}'
    - runas: {{ lgsm.os.user }}
    - creates: {{ lgsm.os.userhomedir }}/{{ lgsm.app }}

lgsm {{ lgsm.app }} auto-install:
  cmd.run:
    - name: './{{ lgsm.app }} auto-install'
    - runas: {{ lgsm.os.user }}
{% if lgsm.os.creates %}
    - creates: {{ lgsm.os.creates }}
{% endif %}

lgsm {{ lgsm.app }} set homedir owner:
  cmd.run:
    - name: "echo $(date) > /home/{{ lgsm.os.user }}/.completed-set-owner.flag && chown -R {{ lgsm.os.user }}:{{ lgsm.os.user }} /home/{{ lgsm.os.user }}"
    - creates: /home/{{ lgsm.os.user }}/.completed-set-owner.flag
{% endif %}
