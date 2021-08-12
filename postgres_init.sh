#!/bin/bash
# postgres init script

if [[ ! -f /var/lib/postgresql/data/postgresql.conf ]]; then
 echo -e "Postgres initialization..."
 cp -rf /etc/postgresql/13/main/* /var/lib/postgresql/data
 cp -rf /var/lib/postgresql/13/main/* /var/lib/postgresql/data
 chown -R postgres:postgres /var/lib/postgresql/data
 chmod 700 -R /var/lib/postgresql/data/*
 chmod 700 -R /var/lib/postgresql/data
 sleep 10
else
 echo -e "Postgres already initialized!"
 chown -R postgres:postgres /var/lib/postgresql/data
 chmod 700 -R /var/lib/postgresql/data/*
 chmod 700 -R /var/lib/postgresql/data
 sleep 10
fi

echo "Postgres start!" >> /tmp/postgres_start
sleep 180
echo "Chainweb-data build!" >> /tmp/chainwebdata_build


