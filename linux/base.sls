{% if 'timezone.system' in pillar %}
set preferred timezone:
  timezone.system:
    - name: {{ pillar['timezone.system'] }}
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
    - name: sshd.service
    - reload: True
    - watch:
      - file: /etc/ssh/sshd_config

{% if 'adminuser' in pillar %}
create adminsuser {{ pillar['adminuser']['id'] }}:
  user.present: {{ pillar['adminuser']['user.present'] }}
  ssh_auth.present: {{ pillar['adminuser']['ssh_auth.present'] }}
wheel group no sudo password:
  file.append:
    - name: /etc/sudoers.d/85-wheel-group
    - text: '%wheel  ALL=(ALL)       NOPASSWD:ALL'
{% endif %}
