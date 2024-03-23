wes:
  user.present:
    - fullname: Wes Belt
    - shell: /bin/bash
    - createhome: True
    - groups:
      - wheel
  ssh_auth.present:
    - user: wes
    - source: salt://ssh_keys/wes.id_rsa.pub
    - config: '%h/.ssh/authorized_keys'