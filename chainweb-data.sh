#!/usr/bin/env bash
# chainweb-data init script
GATEWAYlocal=$(hostname -i | sed 's/\.[^.]*$/.1/')
GATEWAY=${GATEWAY:-$GATEWAYlocal}
GATEWAYPORT=${GATEWAYPORT:-31350}
SERVICEPORT=${SERVICEPORT:-31351}
GATEWAYPROTOCOL=${GATEWAYPROTOCOL:-https}
function node_await() {
 check=$(curl -SsL -k -m 15 $GATEWAYPROTOCOL://$GATEWAY:$GATEWAYPORT/chainweb/0.0/mainnet01/cut  2>/dev/null | jq .height 2>/dev/null)
 if [[ "$check" == "" ]]; then
   until [ $check != "" ] ; do
     check=$(curl -SsL -k -m 15 $GATEWAYPROTOCOL://$GATEWAY:$GATEWAYPORT/chainweb/0.0/mainnet01/cut 2>/dev/null | jq .height 2>/dev/null)
     echo -e "Waiting for KDA node..."
     sleep 200
   done
 fi
}

function update() {
   echo -e "Checking update...."
   cd /usr/local/bin
   local_version=$(cat VERSION)
   remote_info=$(curl -SsL -m 10 "https://api.github.com/repos/kadena-io/chainweb-data/releases/latest" | jq -r .)
   URL=$((jq -r .assets[].browser_download_url <<< "$remote_info") | grep "$UBUNTUVER")
   remote_version=$(jq -r .tag_name <<< "$remote_info")
   if [[ "$local_version" != "$remote_version" ]] && [[ "$local_version" != "" &&  "$remote_version" != "" ]]; then
     echo -e "Local version: $local_version, Remote version: $remote_version"
     rm -rf *
     echo "$remote_version" > VERSION
     echo "Downloading file: ${URL}"
     wget "${URL}"
     unzip *.zip
     rm -rf *.zip
     chmod +x chainweb-data
   else
     echo -e "You have the latest version..."
   fi
}

if [[ "$1" == "start" ]]; then
  echo -e "Checking postgreSQL..."
  status=$(pg_ctlcluster ${PG_VERSION} main status)
  if [[ $(grep "server is running" <<< "$status") ]]; then
    echo -e "PostgreSQL server is running..."
    sleep 40
  else
    echo -e "Waiting for postgreSQL..."
    sleep 60
  fi
  if [[ "$AUTOUPDATE" == 1 ]]; then
    update
  else
    echo "Auto update disabled..."
  fi
  node_await
  echo -e "Starting chainweb-data..."
  chainweb-data server --port 8888 --service-host=$GATEWAY --p2p-host=$GATEWAY --service-port=$SERVICEPORT --p2p-port=$GATEWAYPORT --dbuser=postgres --dbpass=postgres --dbname=postgres -m +RTS -N
fi

if [[ "$1" == "update" ]]; then
  kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
  update
fi
