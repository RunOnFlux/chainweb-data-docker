#!/bin/bash
# postgres init script

if [[ ! -f /var/lib/postgresql/data/postgresql.conf ]]; then
 echo -n "Postgres initialization..."
 chown -R postgres:postgres /var/lib/postgresql/data
 chmod 700 -R /var/lib/postgresql/data/*
 cp -rf /etc/postgresql/13/main/* /var/lib/postgresql/data
 cp -rf /var/lib/postgresql/13/main/* /var/lib/postgresql/data
 chown -R postgres:postgres /var/lib/postgresql/data
 chmod 700 -R /var/lib/postgresql/data/*
 sleep 10
else
 echo -n "Postgres already initialized!"
 chown -R postgres:postgres /var/lib/postgresql/data
 chmod 700 -R /var/lib/postgresql/data/*
 sleep 10
fi

