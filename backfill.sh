#!/bin/bash
# chainweb-data db sync script


if [[ -f /tmp/backfill ]]; then
  echo -n "Backfill already done! skipped..."
  exit
fi

x=0

until [ $x == 1 ] ; do
  
  
  sleep 1000
  server_check=$(ps aux | grep idle | wc -l)
  if [[ "$server_check" == 2 ]]; then
    chainweb-data backfill --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=30005 --p2p-port=30004 --dbuser=postgres --dbpass=postgres --dbname=postgres
    sleep 5
    x=1
    echo "B1ackfill complited!" >> /tmp/backfill
    (crontab -l -u "$USER" 2>/dev/null; echo "30 2 * * * /gaps.sh") | crontab -
  fi

done
