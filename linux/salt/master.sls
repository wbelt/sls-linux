salt install master packages:
  pkg.installed:
    - refresh: True
    - pkgs: salt-master
salt master server gitup:
  file.managed:
    - name: /usr/local/bin/gitup
    - source: salt://diydev/files/salt/master/gitup
    - mode: "0755"
salt master file export:
  file.extract:
    - name: /
    - source: salt://diydev/files/salt/master/<<export master>>.tgz
