#!/usr/bin/env bash
# postgres luncher
trap stop_script SIGINT SIGTERM
function stop_script(){
  echo -e "Stopping postgres..."
  pg_ctlcluster ${PG_VERSION} main stop -m fast
  sleep 5
  pg_ctlcluster ${PG_VERSION} main stop -m fast
}

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
pg_ctlcluster ${PG_VERSION} main start
#/usr/lib/postgresql/${PG_VERSION}/bin/postgres -D /var/lib/postgresql/data -c config_file=/var/lib/postgresql/data/postgresql.conf
