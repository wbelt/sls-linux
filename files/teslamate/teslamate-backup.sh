#!/bin/bash
BACKUPFILE="teslamate-database-backup.tgz"
banner_help()
{
  echo $0
  echo ""
  echo $1
  echo ""
  echo "    select option"
  echo ""
  echo "      --over-write  - Overwrite backup file if it already exists"
  echo ""
}
perform_backup()
{
  echo "Performing backup to ${BACKUPFILE}..."
  podman exec -t systemd-teslamate-database pg_dump -U teslamate teslamate | gzip -c > $BACKUPFILE
}
if [ -z $1 ]; then
  if [ -f $BACKUPFILE ]; then
    banner_help "Backup File ${BACKUPFILE} already exists and over-write not provided!"
  else
    perform_backup
  fi
else
  if [ "$1" == "--over-write" ]; then
    if [ -f $BACKUPFILE ]; then
      echo "Removing file ${BACKUPFILE} per over-write flag..."
      rm $BACKUPFILE
    fi
    perform_backup
  else
    banner_help "Unknown option ${1}"
  fi
fi
