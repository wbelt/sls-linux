{% if 'wes' in pillar %}
wes:
  user.present: {{ pillar['wes']['user.present'] }}
  ssh_auth.present: {{ pillar['wes']['ssh_auth.present'] }}
wheel group no sudo password:
  file.replace:
    - name: /etc/sudoers.d/85-wheel-group
    - append_if_not_found: True
    - pattern: ^%wheel .*$
    - repl: %wheel  ALL=(ALL)       NOPASSWD:ALL
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
{% endif %}
