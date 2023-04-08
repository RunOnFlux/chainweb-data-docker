#!/bin/bash
# chainweb-data db sync script
PATH_DATA="/var/lib/postgresql/data"
GATEWAYIP=$(hostname -i | sed 's/\.[^.]*$/.1/')
MIN_BLOCKS=200

function cronJob(){
    [ -f /var/spool/cron/crontabs/root ] && crontab_check=$(cat /var/spool/cron/crontabs/root| grep -o gaps | wc -l) || crontab_check=0
    if [[ "$crontab_check" == "0" ]]; then
      echo -e "Added crone job for fill as gaps..."
      (crontab -l -u root 2>/dev/null; echo "30 22 * * *  /bin/bash /gaps.sh > /tmp/fill_output.log 2>&1") | crontab -
    fi
}

check=$(curl -SsL -k -m 15 https://$GATEWAYIP:31350/chainweb/0.0/mainnet01/cut 2>/dev/null | jq .height 2>/dev/null)
if [[ "$check" == "" ]]; then
  until [[ "$check" != "" ]] ; do
    check=$(curl -SsL -k -m 15 https://$GATEWAYIP:31350/chainweb/0.0/mainnet01/cut 2>/dev/null | jq .height 2>/dev/null) 
    echo -e "Waiting for KDA node..."
    sleep 300
  done
fi

if [[ -f $PATH_DATA/BACKFILL ]]; then
    cronJob
    echo -e "Running fill as gaps..."
    chainweb-data fill --service-host=$GATEWAYIP --p2p-host=$GATEWAYIP --service-port=31351 --p2p-port=31350 --dbuser=postgres --dbpass=postgres --dbname=postgres
    echo -e "Restarting chainweb-data..."
    kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
    exit
fi
x=0
backfill_count=0
until [[ "$x" == 1 ]] ; do
  if [[ "$backfill_count" == 0 ]]; then
    echo "Initial waiting to receive a block on each chain..."
    sleep 120
  else
    sleep 60
  fi
  server_check=$(ps aux | grep idle | wc -l)
  if [[ "$server_check" -ge 2 ]]; then
    #CLEAN OLD LOGS
    echo "" > /var/lib/postgresql/data/fill.log
    date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "Fill started at $date_timestamp"
    chainweb-data fill --service-host=$GATEWAYIP --p2p-host=$GATEWAYIP --service-port=31351 --p2p-port=31350 --dbuser=postgres --dbpass=postgres --dbname=postgres +RTS -N
    sleep 10
    progress_check=$(cat /var/lib/postgresql/data/fill.log | egrep -o 'Progress:.*[0-9]+\.[0-9]+.*' | egrep -o '[0-9]+\.[0-9]+' | tail -n1)
    date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    filled_blocks=cat $(cat /var/lib/postgresql/data/fill.log  | grep -oP '(?<=Filled in ).*(?= missing blocks.)' | tail -n1)
    backfill_count=$((backfill_count+1))
    
    if [[ "$progress_check" != "" ]]; then
      echo -e "Fill progress: $progress_check %, stopped at $date_timestamp, counter: $backfill_count"
      echo -e "Filled:  $filled_blocks blocks. (LIMIT: $MIN_BLOCKS)"
    else
      echo -e "Fill stopped at $date_timestamp, counter: $backfill_count"
      echo -e "Filled:  $filled_blocks blocks. (LIMIT: $MIN_BLOCKS)"
    fi
    
    if [[ "$progress_check" -ge 98 || "$filled_blocks" -le "$MIN_BLOCKS" ]]; then
      x=1
      echo -e "FILL COMPLITED!" >> $PATH_DATA/BACKFILL
      echo -e "Restarting chainweb-data..."
      kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
      cronJob
      exit
    fi
  fi  
done
