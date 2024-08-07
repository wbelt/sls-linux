#!/bin/bash
rm tm.bck
podman exec -t systemd-teslamate-database pg_dump -U teslamate teslamate > tm.bck
tar -czf tm.tgz tm.bck
