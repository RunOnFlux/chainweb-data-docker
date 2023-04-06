#!/usr/bin/env bash
# postgres luncher

if [[ "$1" == "start" ]]; then
  echo -e "Starting postgres..."
  /usr/lib/postgresql/${PG_VERSION}/bin/postgres -D /var/lib/postgresql/data -c config_file=/var/lib/postgresql/data/postgresql.conf
  sleep 15
fi

if [[ "$1" == "stop" ]]; then
  echo -e "Stopping postgres..."
  supervisorctl stop postgres_start > /dev/null 2>&1
  pg_ctlcluster ${PG_VERSION} main stop -m fast
fi
