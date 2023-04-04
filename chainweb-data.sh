#!/bin/bash
# chainweb-data init script
GATEWAYIP=$(hostname -i | sed 's/\.[^.]*$/.1/')

function node_await() {
 check=$(curl -SsL -k -m 15 https://$GATEWAYIP:31350/chainweb/0.0/mainnet01/cut  2>/dev/null | jq .height 2>/dev/null)
 if [[ "$check" == "" ]]; then
   until [ $check != "" ] ; do
     check=$(curl -SsL -k -m 15 https://$GATEWAYIP:31350/chainweb/0.0/mainnet01/cut 2>/dev/null | jq .height 2>/dev/null)
     echo -e "Waiting for KDA node..."
     sleep 200
   done
 fi
}

x=0
until [ $x == 1 ] ; do
  echo -e "Waiting for chainwebdata_build marker..."
  if [[ -f /tmp/chainwebdata_build ]]; then
    echo -e "Starting chainweb-data server..."
    x=1
  else
    sleep 60
  fi
done

 if [[ -f /usr/local/bin/chainweb-data ]]; then
   node_await
   chainweb-data server --port 8888 --service-host=$GATEWAYIP --p2p-host=$GATEWAYIP --service-port=31351 --p2p-port=31350 --dbuser=postgres --dbpass=postgres --dbname=postgres -m
   exit
 fi
