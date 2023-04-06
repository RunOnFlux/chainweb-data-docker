#!/usr/bin/env bash
# postgres luncher

if [[ "$1" == "start" ]]; then
  echo -e "Starting postgres..."
  /usr/lib/postgresql/${PG_VERSION}/bin/postgres -D /var/lib/postgresql/data -c config_file=/var/lib/postgresql/data/postgresql.conf
  sleep 15
fi

if [[ "$1" == "stop" ]]; then
  echo -e "Stopping postgres..."
  supervisorctl stop postgres_start
  pg_ctlcluster ${PG_VERSION} main stop -m fast
fi

if [[ "$1" == "backup" ]]; then
  echo -e "Starting backup..."
  mkdir -p  /var/lib/postgresql/data/backup
  cd /var/lib/postgresql/data/backup
  if [[ -f /var/lib/postgresql/data/backup/chainweb-data-backup.tar ]]; then
    rm -rf /var/lib/postgresql/data/backup/chainweb-data-backup.tar
  fi
  pg_dump -U postgres -Fc postgres > chainweb-data-backup.tar
  size=$(ls -lh chainweb-data-backup.tar | awk '{ print $5 }')
  echo -e "Backup created, size: $size"
fi

if [[ "$1" == "restore" ]]; then
  echo -e "Restoring backup..."
  if [[ -f /var/lib/postgresql/data/backup/chainweb-data-backup.tar ]]; then
    pg_restore -d postgres /var/lib/postgresql/data/backup/chainweb-data-backup.tar -c -U postgres
    echo -e "Operation complited!"
  else
    echo -e "Backup archive not found!"
  fi
fi
