#!/bin/bash
# chainweb-data gaps


if [[ ! -f /tmp/backfill ]]; then
  echo -n "Backfill not complited...Gaps skipped!""
  exit
fi

chainweb-data gaps --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=30005 --p2p-port=30004 --dbuser=postgres --dbpass=postgres --dbname=postgres

