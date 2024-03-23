{% if 'wes' in pillar %}
wes:
  user.present: {{ pillar['wes']['user.present'] }}
  ssh_auth.present: {{ pillar['wes']['ssh_auth.present'] }}
wheel group no sudo password:
  file.line:
    - name: /etc/sudoers.d/85-wheel-group
    - content: '%wheel  ALL=(ALL)       NOPASSWD:ALL'
    - match: '%wheel .*'
    - mode: insert
    - location: end
    - create: True
{% endif %}
