reboot-system:
  cmd.run:
    - name: reboot
    - order: last
    - bg: true
