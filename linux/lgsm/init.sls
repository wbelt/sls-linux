{% if lgsm_os.defname is defined %}

lgsm {{ lgsm_os.defname }} package install:
  pkg.latest: [ { refresh: True, pkgs: {{ lgsm_os.packages.latest }} } ]

{% if grains['os'] == 'Ubuntu' %}
lgsm {{ lgsm_os.defname }} debconf set:
  debconf.set:
    - name: dash
    - data:
        steam/question: {'type': 'select', 'value': 'I AGREE'}
        steam/license: {'type': 'note', 'value': ''}

lgsm {{ lgsm_os.defname }} i386 install:
  cmd.run:
    - name: 'dpkg --add-architecture i386; apt update; DEBIAN_FRONTEND=noninteractive apt install --yes {{ lgsm_os.packages.i386 | join(" ") }}'
    - creates: /usr/games/steamcmd
{% endif %}

lgsm {{ lgsm_os.defname }} user creation:
  user.present: [ {{ lgsm_os.user_present }} ]

lgsm {{ lgsm_os.defname }} download:
  cmd.run:
    - name: 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh {{ defname }}'
    - runas: {{ lgsm_os.user }}
    - creates: {{ lgsm_os.userhomedir }}/{{ lgsm_os.defname }}

lgsm {{ lgsm_os.defname }} auto-install:
  cmd.run:
    - name: './{{ lgsm_os.defname }} auto-install'
    - runas: {{ lgsm_os.user }}
{% if lgsm_os.creates %}
    - creates: {{ lgsm_os.creates }}
{% endif %}

lgsm {{ lgsm_os.defname }} set homedir owner:
  cmd.run:
    - name: "echo $(date) > /home/{{ lgsm_os.user }}/.completed-set-owner.flag && chown -R {{ lgsm_os.user }}:{{ lgsm_os.user }} /home/{{ lgsm_os.user }}"
    - creates: /home/{{ lgsm_os.user }}/.completed-set-owner.flag
{% endif %}
