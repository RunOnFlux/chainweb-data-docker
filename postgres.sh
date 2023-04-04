#!/bin/bash
# postgres luncher
x=0
until [[ "$x" == 1 ]] ; do
  echo -e "Waiting for postgres marker..."
  if [[ -f /tmp/postgres_start ]]; then
    echo -e "Starting postgres..."
    sleep 10
    x=1
  else
    sleep 15
  fi
done
/usr/lib/postgresql/15/bin/postgres -D /var/lib/postgresql/data -c config_file=/var/lib/postgresql/data/postgresql.conf
