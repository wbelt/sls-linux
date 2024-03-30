sshport:
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
