#!/bin/bash
# postgres init script

function with_backoff() {
  local max_attempts=${ATTEMPTS-5}
  local timeout=${TIMEOUT-1}
  local attempt=1
  local exitCode=0

  while (($attempt < $max_attempts)); do
    if "$@"; then
      echo "Extracting bootstrap to $DBDIR"
      tar -xzvf bootstrap.tar.gz -C "$DBDIR"
      rm /var/lib/postgresql/data/bootstrap.tar.gz
      echo "Bootstrap extract finish"
      return 0
    else
      exitCode=$?
    fi

    echo "Failure! Retrying in $timeout.." 1>&2
    sleep $timeout
    attempt=$((attempt + 1))
    timeout=$((timeout * 2))
  done

  if [[ $exitCode != 0 ]]; then
    rm -rf /var/lib/postgresql/data/bootstrap.tar.gz
    rm /tmp/bootstrap
    echo "Failed for the last time! ($@)" 1>&2
  fi

  return $exitCode
}

# DBDIR="/var/lib/postgresql/data"
# CFILE="/var/lib/postgresql/data/postgresql.conf"

# Double check if dbdir already exists, only download bootstrap if it doesn't
#if [ -f $CFILE ]; then
#  echo "Bootstrap skipped!..."
# else
#  echo "Bootstrap marker" >> /tmp/bootstrap
#  BOOTSTRAPLOCATIONS[0]="https://fluxnodeservice.com/chainwebdata_bootstrap.tar.gz"
#  BOOTSTRAPLOCATIONS[1]="https://cdn-3.runonflux.io/zelapps/zelshare/getfile/chainwebdata_bootstrap.tar.gz"
#  BOOTSTRAPLOCATIONS[2]="https://fluxnodeservice.com/chainwebdata_bootstrap.tar.gz"
#  BOOTSTRAPLOCATIONS[3]="https://cdn-3.runonflux.io/zelapps/zelshare/getfile/chainwebdata_bootstrap.tar.gz"
#
#  retry=0
#  file_lenght=0
#  while [[ "$file_lenght" -lt "100000" && "$retry" -lt 6 ]]; do
#    index=$(shuf -i 0-3 -n 1)
#    echo "Testing bootstrap location ${BOOTSTRAPLOCATIONS[$index]}"
#    file_lenght=$(curl -sI -m 5 ${BOOTSTRAPLOCATIONS[$index]} | egrep 'Content-Length|content-length' | sed 's/[^0-9]*//g')
#
#    if [[ "$file_lenght" -gt "100000" ]]; then
#      echo "File lenght: $file_lenght"
#    else
#      echo "File not exist! Source skipped..."
#    fi
#    retry=$(expr $retry + 1)
#  done


 # if [[ "$file_lenght" -gt "100000" ]]; then
 #   echo "Bootstrap location valid"
 #   echo "Downloading bootstrap...."
 #   # Install database
 #   with_backoff curl --keepalive-time 30 \
 #     -C - \
 #     -o bootstrap.tar.gz "${BOOTSTRAPLOCATIONS[$index]}"
 # else
 #   echo "None bootstrap was found, backfill will be run"
 #   rm /tmp/bootstrap
 # fi
# fi

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
echo "Chainweb-data build!" >> /tmp/chainwebdata_build


