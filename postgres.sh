#!/usr/bin/env bash
# postgres luncher

if [[ "$1" == "start" ]]; then
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
/usr/lib/postgresql/${PG_VERSION}/bin/postgres -D /var/lib/postgresql/data -c config_file=/var/lib/postgresql/data/postgresql.conf
fi

if [[ "$1" == "stop" ]]; then
  echo -e "Stopping postgres..."
  supervisorctl stop postgres > /dev/null 2>&1
  pg_ctlcluster ${PG_VERSION} main stop -m fast
fi
