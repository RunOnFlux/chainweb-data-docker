#!/bin/bash

if [[ ! -f /tmp/backfill ]]; then
    echo -e "Fill not complited...skipped..."  
fi

date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo -e "Fill was started at $date_timestamp" >> /tmp/fill_history.log
/usr/local/bin/chainweb-data fill --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=31351 --p2p-port=31350 --dbuser=postgres --dbpass=postgres --dbname=postgres
date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo -e "Fill was ended at $date_timestamp" >> /tmp/fill_history.log
