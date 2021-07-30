#!/usr/bin/env bash

  if [[ -f /tmp/bootstrap ]]; then   
     if [[ -f /var/lib/postgresql/data/bootstrap.tar.gz ]]; then
       echo "Initialization: postgres bootstraping..."  
       exit 
     fi   
  fi
  
check=$(supervisorctl status | egrep  'chainweb-data|postgres' | grep RUNNING | wc -l)

if [[ "$check" == 2 ]]; then

  check_api_listening=$(sudo lsof -i -P -n | grep -o 8888)
  if [[ "$check_api_listening" != "" ]]; then
    status="ONLINE"
  else
    status="OFFLINE"
  fi

 if [[ -f /tmp/backfill ]]; then
 
   if [[ -f /tmp/bootstrap ]]; then 
     echo "chainweb-data: running ($status), postgres: running, bootstrap: complited" 
   else
     echo "chainweb-data: running ($status), postgres: running, backfill: complited" 
   fi
    
 else
    progress=$(cat $(ls /var/log/supervisor | grep chainweb-backfill-stdout | awk {'print "/var/log/supervisor/"$1'} ) | tail -n1 | egrep -o -E 'Progress: [0-9]+.{5}[0-9]+.*minute.')
     if [[ "$progress" == "" ]]; then
       progress='awaiting...'
     else    
       freez_check=$(cat $(ls /var/log/supervisor | grep chainweb-backfill-stdout | awk {'print "/var/log/supervisor/"$1'} ) | tail -n3 | egrep -o -E 'Progress: [0-9]+.{5}[0-9]+.*minute.' | egrep -o -E '[0-9]+\.[0-9]+' | awk '{sum += $1} END {print sum-(3*$1)}')
       if [[ "$freez_check" == 0 ]]; then
          echo "Postgres info: insert query hangs, backfill not finished! PC restart required"
          exit 1
       fi      
     fi  
     echo "chainweb-data: running ($status), postgres: running, backfill: running $progress"
 fi
  
else
  exit 1
fi

