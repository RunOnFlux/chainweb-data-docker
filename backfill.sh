#!/bin/bash
# chainweb-data db sync script
check=$(curl -SsL -k -m 15 https://172.15.0.1:30004/chainweb/0.0/mainnet01/cut | jq .height)
if [[ "$check" == "" ]]; then
  until [[ "$check" != "" ]] ; do
    check=$(curl -SsL -k -m 15 https://172.15.0.1:30004/chainweb/0.0/mainnet01/cut | jq .height)
    echo -e "Waiting for KDA node..."
    sleep 300
  done
fi

if [[ -f /tmp/backfill ]]; then
    echo -e "Backfill already done! skipped..."
    echo -e "Running gaps..."
    chainweb-data gaps --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=30005 --p2p-port=30004 --dbuser=postgres --dbpass=postgres --dbname=postgres
    echo -e "Restarting chainweb-data..."
    kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
    exit
fi

x=0
backfill_count=0

until [[ "$x" == 1 ]] ; do

  if [[ -f /usr/local/bin/chainweb-data ]]; then
   # give time postgres to run
    sleep 600
  else
    # Allow time to build chainweb-data binary and for postgres to run
    sleep 1000
  fi
 
  server_check=$(ps aux | grep idle | wc -l)

  if [[ "$server_check" == 2 ]]; then

    date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "Backfill started at $date_timestamp"
    chainweb-data backfill --delay 5 --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=30005 --p2p-port=30004 --dbuser=postgres --dbpass=postgres --dbname=postgres +RTS -N
    sleep 10
    progress_check=$(cat $(ls /var/log/supervisor | grep chainweb-backfill-stdout | awk {'print "/var/log/supervisor/"$1'} ) | tail -n1 | egrep -o -E '[0-9]+\.[0-9]+' | egrep -o -E '[0-9]+' | head -n1 )
    date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    backfill_count=$((backfill_count+1))

     if [[ "$progress_check" != "" ]]; then
      echo -e "Backfill progress: $progress_check %, stopped at $date_timestamp, counter: $backfill_count"
     else
      echo -e "Backfill stopped at $date_timestamp, counter: $backfill_count"
     fi

     if [[ "$progress_check" -ge 70 ]]; then
       x=1
       echo -e "Backfill Complited!" >> /tmp/backfill
       echo -e "Running gaps..."
       chainweb-data gaps --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=30005 --p2p-port=30004 --dbuser=postgres --dbpass=postgres --dbname=postgres
       echo -e "Restarting chainweb-data..."
       kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
       if [[ ! -f /tmp/crone ]]; then
         sleep 600
         echo -e "Added crone job for gaps..."
         (crontab -l -u "$USER" 2>/dev/null; echo "30 22 * * *  /bin/bash /gaps.sh > /tmp/gaps_output.log 2>&1") | crontab -
         echo -e "Cron job added!" >> /tmp/crone
       else
         echo -e "Cron job already exist..."
       fi
       exit
     fi

     if [[ "$progress_check" == "" && "$backfill_count" == 2 ]] ; then
        x=1
        echo -e "Backfill Complited!" >> /tmp/backfill
        echo -e "Running gaps..."
        chainweb-data gaps --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=30005 --p2p-port=30004 --dbuser=postgres --dbpass=postgres --dbname=postgres
        echo -e "Restarting chainweb-data..."
        kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
        if [[ ! -f /tmp/crone ]]; then
          sleep 600
          echo -e "Added crone job for gaps..."
          (crontab -l -u "$USER" 2>/dev/null; echo "30 22 * * *  /bin/bash /gaps.sh > /tmp/gaps_output.log 2>&1") | crontab -
          echo -e "Crone job added!" >> /tmp/crone
         else
          echo -e "Crone job already exist..."
        fi
        exit
      fi
  fi
done
