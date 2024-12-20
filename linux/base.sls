{% if grains['os_family'] in ['Debian'] %}
  {% set sshd_name = 'ssh.service' %}
{% else %}
  {% set sshd_name = 'sshd.service' %}
{% endif %}

set preferred timezone:
  timezone.system:
    - name: America/New_York

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
