#!/bin/bash
if [ -z $1 ]; then
  echo $0
  echo ""
  echo "provide file name for restore"
  echo ""
else
  if [ -f $1 ]; then
    systemctl --user stop teslamate-teslamate teslamate-grafana
    podman exec -i systemd-teslamate-database psql -U {{ pillar['teslamate']['database_user'] }} {{ pillar['teslamate']['database_name'] }} << .
drop schema public cascade;
create schema public;
create extension cube;
create extension earthdistance;
CREATE OR REPLACE FUNCTION public.ll_to_earth(float8, float8)
    RETURNS public.earth
    LANGUAGE SQL
    IMMUTABLE STRICT
    PARALLEL SAFE
    AS 'SELECT public.cube(public.cube(public.cube(public.earth()*cos(radians(\$1))*cos(radians(\$2))),public.earth()*cos(radians(\$1))*sin(radians(\$2))),public.earth()*sin(radians(\$1)))::public.earth';
\q
.
    /usr/bin/gzip -dc $1 | podman exec -i systemd-teslamate-database psql -U {{ pillar['teslamate']['database_user'] }} -d {{ pillar['teslamate']['database_name'] }}
    systemctl --user start teslamate-grafana teslamate-teslamate
  fi
fi