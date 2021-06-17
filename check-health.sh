#!/usr/bin/env bash

check=$(supervisorctl status | egrep  'chainweb-data|postgres' | grep RUNNING | wc -l)
if [[ "$check" == 2 ]]; then 
  if [[ -f "/tmp/backfill" ]]; then
    echo "chainweb-data: running, postgres: running, backfill: complited"
  else
    progress=$(cat $(ls /var/log/supervisor | grep chainweb-backfill-stdout | awk {'print "/var/log/supervisor/"$1'} ) | tail -n1 | egrep -o -E '[0-9]+\.[0-9]+.')
    echo "chainweb-data: running, postgres: running, backfill: running ($progress)"
  fi
else 
  exit 1
fi
