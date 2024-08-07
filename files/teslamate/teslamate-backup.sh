#!/bin/bash
BACKUPFILE="teslamate-database-backup.tgz"
perform_backup()
{
  podman exec -t systemd-teslamate-database pg_dump -U teslamate teslamate | gzip -c > $BACKUPFILE
}

if [ -z $1 ]; then
  if [ -f $BACKUPFILE ]; then
    echo $0
    echo ""
    echo "Backup File ${1} already exists and over-write not provided!"
    echo ""
    echo "    select option"
    echo ""
    echo "      --over-write  - Overwrite backup file if it already exists"
    echo ""
  else
    perform_backup
  fi
else
  if [ "$1" == "--over-write" ]; then
    if [ -f $BACKUPFILE ]; then
      rm $BACKUPFILE
    fi
    perform_backup
  else
    echo $0
    echo ""
    echo "Unknown option {$1}"
    echo ""
    echo "    select option"
    echo ""
    echo "      --over-write  - Overwrite backup file if it already exists"
    echo ""
  fi
fi
