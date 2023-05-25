#!/bin/bash
GATEWAYIP=$(hostname -i | sed 's/\.[^.]*$/.1/')
PATH_DATA="/var/lib/postgresql/data"

if [[ ! -f $PATH_DATA/BACKFILL ]]; then
    echo -e "Fill not complited...skipped..."  
    exit
fi

date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo -e "Fill was started at $date_timestamp" >> /tmp/fill_history.log
/usr/local/bin/chainweb-data fill --service-host=$GATEWAYIP --p2p-host=$GATEWAYIP --service-port=31351 --p2p-port=31350 --dbuser=postgres --dbpass=postgres --dbname=postgres
date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo -e "Fill was ended at $date_timestamp" >> /tmp/fill_history.log
