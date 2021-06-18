#!/usr/bin/env bash

check=$(supervisorctl status | egrep  'chainweb-data|postgres' | grep RUNNING | wc -l)

if [[ "$check" == 2 ]]; then

check_api_listening=$(sudo lsof -i -P -n | grep -o 8888)

  if [[ "$check_api_listening" != "" ]]; then
    status="ONLINE"
  else
    status="OFFLINE"
  fi

  if [[ -f "/tmp/backfill" ]]; then
    echo "chainweb-data: running ($status), postgres: running, backfill: complited"
  else
    progress=$(cat $(ls /var/log/supervisor | grep chainweb-backfill-stdout | awk {'print "/var/log/supervisor/"$1'} ) | tail -n1 | egrep -o -E '[0-9]+\.[0-9]+.')
    echo "chainweb-data: running, postgres: running, backfill: running ($progress)"
  fi

else
  exit 1
fi

