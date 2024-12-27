{% if grains['os_family'] in ['Debian'] %}
  {% set sshd_name = 'ssh.service' %}
  {% set sudo_group = 'sudo' %}
{% else %}
  {% set sshd_name = 'sshd.service' %}
  {% set sudo_group = 'wheel' %}
{% endif %}

{% if 'linux' in pillar %}
{% if 'timezone' in pillar['linux'] %}
set preferred timezone:
  timezone.system:
    - name: {{ pillar['linux']['timezone'] }}
{% endif %}

set custom ssh port:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^(P|#P)ort .*$'
{% if 'rustserver' in pillar %}
    - repl: 'Port 28022'
{% else %}
    - repl: 'Port 25022'
{% endif %}
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False

restart ssh if needed:
  service.running:
    - name: {{ sshd_name }}
    - reload: True
    - watch:
      - file: /etc/ssh/sshd_config

{% if 'adminuser' in pillar['linux'] %}
{% set adminref = pillar['linux']['adminuser'] %}
create adminsuser {{ adminref['id'] }}:
  user.present: {{ adminref['user.present'] }}
  ssh_auth.present: {{ adminref['ssh_auth.present'] }}
add adminsuser {{ adminref['id'] }} to sudo group:
  user.present.groups:
    - name: {{ adminref['id'] }}
    - groups: [ {{ sudo_group }} ]
wheel group no sudo password:
  file.append:
    - name: /etc/sudoers.d/85-{{ sudo_group }}-group
    - text: '%{{ sudo_group }}  ALL=(ALL)       NOPASSWD:ALL'
{% endif %}
include:
  - .scp-utils
{% endif %}
