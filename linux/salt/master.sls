salt install master packages:
  pkg.installed:
    - refresh: True
    - pkgs: salt-master
