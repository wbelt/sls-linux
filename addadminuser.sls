{% if 'user' in pillar %}
{{ pillar['user']['id'] }}:
  user.present: {{ pillar['user']['user.present'] }}
  ssh_auth.present: {{ pillar['user']['ssh_auth.present'] }}
wheel group no sudo password:
  file.append:
    - name: /etc/sudoers.d/85-wheel-group
    - text: '%wheel  ALL=(ALL)       NOPASSWD:ALL'
{% endif %}
