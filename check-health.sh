#!/usr/bin/env bash
PATH_DATA="/var/lib/postgresql/data"
LOG_PATH="/var/lib/postgresql/data/fill.log"

check=$(supervisorctl status | egrep  'chainweb-data|postgres' | grep RUNNING | wc -l)
if [[ "$check" == 2 ]]; then
  check_api_listening=$(lsof -i -P -n | grep -o 8888)
  if [[ "$check_api_listening" != "" ]]; then
    status="ONLINE"
  else
    status="OFFLINE"
  fi
 if [[ -f /var/lib/postgresql/data/BACKFILL ]]; then
     echo "chainweb-data: running ($status), postgres: running, fill: complited"
 else
    progress=$(cat $LOG_PATH | egrep -o -E 'Progress: [0-9]+.{5}[0-9]+.*' | egrep -o '[0-9]+\.[0-9]+' | tail -n1)
     if [[ "$progress" == "" ]]; then
       progress='awaiting...'
     else
       freez_check=$(cat $LOG_PATH | egrep -o 'Progress:.*[0-9]+\.[0-9]+.*' | egrep -o '[0-9]+\.[0-9]+' | tail -n3 | awk '{sum += $1} END {print sum-(3*$1)}')
       if [[ "$freez_check" == 0 ]]; then
          echo "Postgres info: insert query hangs, fill not finished! PC restart required"
          exit 1
       fi
     fi
     echo "chainweb-data: running ($status), postgres: running, fill: running | $progress"
 fi
else
  exit 1
fi
