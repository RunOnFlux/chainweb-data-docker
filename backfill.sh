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
    #echo -e "Restarting chainweb-data..."
    #kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
    exit
fi
x=0
backfill_count=0
until [[ "$x" == 1 ]] ; do
  if [[ "$backfill_count" == 0 ]]; then
    echo "Initial waiting to receive a block on each chain..."
    sleep 150
    if [[ ! -f $PATH_DATA/INDEX ]]; then 
      psql -U postgres -d postgres -c "create extension pg_trgm;"
      psql -U postgres -d postgres -c 'CREATE INDEX "transactions-requestkey" ON public.transactions USING btree (requestkey);'
      psql -U postgres -d postgres -c 'CREATE INDEX "transactions-code" ON public.transactions USING gin (code gin_trgm_ops);'
      psql -U postgres -d postgres -c 'CREATE INDEX "events-qualname" ON public.events USING gin (qualname gin_trgm_ops);'
      psql -U postgres -d postgres -c 'CREATE INDEX "events-paramtext" ON public.events USING gin (paramtext gin_trgm_ops);'
      echo -e "INDEX CREATED" >> $PATH_DATA/INDEX
    fi
  else
    sleep 60
  fi
  server_check=$(ps aux | grep idle | wc -l)
  if [[ "$server_check" -ge 2 ]]; then
    date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "Fill started at $date_timestamp"
    chainweb-data fill --service-host=$GATEWAYIP --p2p-host=$GATEWAYIP --service-port=31351 --p2p-port=31350 --dbuser=postgres --dbpass=postgres --dbname=postgres +RTS -N
    sleep 10
    
    line_number=$(grep -no 'DB Tables Initialized' $PATH_DATA/fill.log | tail -n1 | egrep -o [0-9]+)
    if [[ "$line_number" == "" ]]; then
      line_number=0
    else
      echo -e "Checking logs belown line $line_number" 
    fi
    
    progress_check=$(awk -v line=$line_number 'NR>line' $PATH_DATA/fill.log | egrep -o 'Progress:.*[0-9]+\.[0-9]+.*' | egrep -o '[0-9]+\.[0-9]+' | tail -n1)
    date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    filled_blocks=$(awk -v line=$line_number 'NR>line' $PATH_DATA/fill.log  | grep -oP '(?<=Filled in ).*(?= missing blocks.)' | tail -n1)
    backfill_count=$((backfill_count+1))
    
    if [[ "$progress_check" != "" ]]; then
      echo -e "Fill progress: $progress_check %, stopped at $date_timestamp, counter: $backfill_count"
      echo -e "Filled: $filled_blocks blocks. (LIMIT: $MIN_BLOCKS)"
    else
      echo -e "Fill stopped at $date_timestamp, counter: $backfill_count"
      echo -e "Filled: $filled_blocks blocks. (LIMIT: $MIN_BLOCKS)"
    fi
    if [[ "$progress_check" -ge 98 ]] || [[ "$filled_blocks" -le "$MIN_BLOCKS"  &&  "$filled_blocks" != "" ]]; then
      x=1
      echo -e "FILL COMPLITED!" >> $PATH_DATA/BACKFILL
      echo -e "Inintial fill status: COMPLITED"
      #echo -e "Restarting chainweb-data..."
      #kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
      cronJob
      exit
    fi
  fi  
done
