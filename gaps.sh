#!/bin/bash
GATEWAYlocal=$(hostname -i | sed 's/\.[^.]*$/.1/')
GATEWAY=${GATEWAY:-$GATEWAYlocal}
GATEWAYPORT=${GATEWAYPORT:-31350}
SERVICEPORT=${SERVICEPORT:-31351}
PATH_DATA="/var/lib/postgresql/data"

if [[ -f $PATH_DATA/BACKFILL ]]; then
    echo -e "Fill not complited...skipped..."  
    exit
fi

date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo -e "Fill was started at $date_timestamp" >> /tmp/fill_history.log
/usr/local/bin/chainweb-data fill --service-host=$GATEWAY --p2p-host=$GATEWAY --service-port=$SERVICEPORT --p2p-port=$GATEWAYPORT --dbuser=postgres --dbpass=postgres --dbname=postgres
date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo -e "Fill was ended at $date_timestamp" >> /tmp/fill_history.log
