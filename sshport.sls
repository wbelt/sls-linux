sshport:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^Port .*$'
    - repl: 'Port 28022'
    - count: 1
    - flags: ['IGNORECASE', 'MULTILINE']
    - backup: False
