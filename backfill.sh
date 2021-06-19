#!/bin/bash
# chainweb-data db sync script
check=$(curl -SsL -k -m 15 https://172.15.0.1:30004/chainweb/0.0/mainnet01/cut | jq .height)
if [[ "$check" == "" ]]; then
  until [ $check != "" ] ; do
    check=$(curl -SsL -k -m 15 https://172.15.0.1:30004/chainweb/0.0/mainnet01/cut | jq .height)
    echo -n "Awaiting for KDA node..."
    sleep 300
  done
fi

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
    (crontab -l -u "$USER" 2>/dev/null; echo "30 22 * * *  /bin/bash /gaps.sh > /tmp/gaps_output.log 2>&1") | crontab -
  fi
done
