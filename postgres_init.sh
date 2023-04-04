#!/bin/bash

if [[ ! -f /var/lib/postgresql/data/postgresql.conf ]]; then
 echo -e "Postgres initialization..."
 cp -rf /etc/postgresql/15/main/* /var/lib/postgresql/data
 cp -rf /var/lib/postgresql/15/main/* /var/lib/postgresql/data
 chown -R postgres:postgres /var/lib/postgresql/data
 chmod 700 -R /var/lib/postgresql/data/*
 chmod 700 -R /var/lib/postgresql/data
else
 echo -e "Postgres already initialized..."
 chown -R postgres:postgres /var/lib/postgresql/data
 chmod 700 -R /var/lib/postgresql/data/*
 chmod 700 -R /var/lib/postgresql/data
fi

echo "Postgres start..." >> /tmp/postgres_start
