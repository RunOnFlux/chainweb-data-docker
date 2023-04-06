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

function update() {
   echo -e "Checking update...."
   cd /usr/local/bin
   file_version=$(ls -a | grep zip)
   PACKAGE=$(curl --silent "https://api.github.com/repos/kadena-io/chainweb-data/releases/latest" | jq -r .assets[].browser_download_url | grep ${UBUNTUVER} ) 
   if [[ $(grep $file_version <<< "$PACKAGE") != "" ]]; then
     rm -rf *.zip chainweb-data
     echo "Downloading file: ${PACKAGE}" 
     wget "${PACKAGE}" 
     unzip * 
     chmod +x chainweb-data
   else
     echo -e "You have the latest version..."
   fi
}

if [[ "$1" == "start" ]]; then
  sleep 20
  update
  node_await
  echo -e "Starting chainweb-data..." 
  chainweb-data server --port 8888 --service-host=$GATEWAYIP --p2p-host=$GATEWAYIP --service-port=31351 --p2p-port=31350 --dbuser=postgres --dbpass=postgres --dbname=postgres -m +RTS -N
fi

if [[ "$1" == "update" ]]; then
  kill -9 $(ps aux | grep 'chainweb-data server --port 8888' | awk '{ print $2 }' | head -n1)
  update
fi
