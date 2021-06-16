#!/usr/bin/env bash

check=$(supervisorctl status | egrep  'chainweb-data|postgres' | grep RUNNING | wc -l)

if [[ "$check" == 2 ]]; then 


  if [[ -f "/tmp/backfill" ]]; then
    echo "chainweb-data: running, postgres: running, backfill: complited"
  else
    echo "chainweb-data: running, postgres: running, backfill: not complited"
  fi

else 
exit 1
fi
