#!/bin/bash
if [ -z $1 ]; then
  echo $0
  echo ""
  echo "provide input file name containing backup data to be restored (example, backup.tar.gz)"
  echo ""
else
  if [ -f $1 ]; then
    echo "Stop teslamate and grafana services..."
    systemctl --user stop teslamate-teslamate teslamate-grafana
    echo "Reset tables..."
    podman exec -i systemd-teslamate-database psql -U {{ pillar['teslamate']['database_user'] }} {{ pillar['teslamate']['database_name'] }} << .
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
CREATE EXTENSION cube WITH SCHEMA public;
CREATE EXTENSION earthdistance WITH SCHEMA public;
.
    echo "Restore data..."
    gzip -dc $1 | podman exec -i systemd-teslamate-database psql -U {{ pillar['teslamate']['database_user'] }} -d {{ pillar['teslamate']['database_name'] }}
    echo "Start grafana and teslamate services..."
    systemctl --user start teslamate-grafana teslamate-teslamate
  fi
fi