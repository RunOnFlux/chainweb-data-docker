#!/bin/bash
# postgres run script

/usr/lib/postgresql/13/bin/postgres -D /var/lib/postgresql/data -c config_file=/var/lib/postgresql/data/postgresql.conf
