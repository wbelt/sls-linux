reboot-on-pending:
  system.reboot:
    - timeout: 5
    - in_seconds: true
    - only_on_pending_reboot: false
    - order: last
