#!/bin/bash
# chainweb-data gaps

if [[ ! -f /tmp/backfill ]]; then
  echo -e "Backfill not complited...Gaps skipped!"
  exit
fi

date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo -e "Gaps was started at $date_timestamp" >> /tmp/gaps_history.log
/usr/local/bin/chainweb-data gaps --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=30005 --p2p-port=30004 --dbuser=postgres --dbpass=postgres --dbname=postgres
date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo -e "Gaps was ended at $date_timestamp" >> /tmp/gaps_history.log
#echo -e "Restarting chainweb-data..."
#kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
