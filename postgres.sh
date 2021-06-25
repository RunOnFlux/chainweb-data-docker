#!/bin/bash
# postgres luncher

x=0
until [ $x == 1 ] ; do

echo -e "Waiting for postgres marker..."
sleep 180

  if [[ -f /tmp/postgres_start ]]; then
    echo -e "Starting postgres..."
    x=1
  fi


done

/usr/lib/postgresql/13/bin/postgres -D /var/lib/postgresql/data -c config_file=/var/lib/postgresql/data/postgresql.conf
