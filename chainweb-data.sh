#!/bin/bash
# chainweb-data init script

function node_await() {
 check=$(curl -SsL -k -m 15 https://172.15.0.1:30004/chainweb/0.0/mainnet01/cut | jq .height)
 if [[ "$check" == "" ]]; then
   until [ $check != "" ] ; do
     check=$(curl -SsL -k -m 15 https://172.15.0.1:30004/chainweb/0.0/mainnet01/cut | jq .height)
     echo -e "Awaiting for KDA node..."
     sleep 200
   done
 fi
}


x=0

until [ $x == 1 ] ; do

echo -e "Waiting for chainwebdata_build marker..."
sleep 180

  if [[ -f /tmp/chainwebdata_build ]]; then
    echo -e "Starting nix && chainweb-data build..."
    x=1
  fi


done



 if [[ -f /usr/local/bin/chainweb-data ]]; then
   node_await
   chainweb-data server --port 8888 --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=30005 --p2p-port=30004 --dbuser=postgres --dbpass=postgres --dbname=postgres
   exit
 fi

 #nix installation 

 export DEBIAN_FRONTEND=noninteractive

 apt update -y 
 apt install -y \
  bzip2 \
  ca-certificates \
  curl \
  locales \
  sudo \
  xz-utils

 localedef -f UTF-8 -i en_US -A /usr/share/locale/locale.alias -c en_US.UTF-8
 groupadd -g 30000 --system nixbld

 for i in $(seq 1 32); do
  useradd \
    --home-dir /var/empty \
    --gid 30000 \
    --groups nixbld \
    --no-user-group \
    --system \
    --shell /usr/sbin/nologin \
    --uid $((30000 + i)) \
    --password "!" \
    nixbld$i
 done

 mkdir -p \
  /root/.config/nix \
  /root/.nixpkgs
 mv /tmp/nix.conf /root/.config/nix/nix.conf
 echo "{ allowUnfree = true; }" > /root/.nixpkgs/config.nix

 cd /tmp
 wget https://nixos.org/releases/nix/nix-2.3/nix-2.3-x86_64-linux.tar.xz 
 xz -d  nix-2.3-x86_64-linux.tar.xz
 tar -xvf nix-2.3-x86_64-linux.tar
 cd nix-2.3-x86_64-linux
 USER=root ./install --no-daemon

 export NIX_PATH=nixpkgs=/root/.nix-defexpr/channels/nixpkgs:/root/.nix-defexpr/channels
 export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
 export PATH=/root/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
 export SUDO_FORCE_REMOVE=yes

 nix-channel --update
 nix-env -iA \
 nixpkgs.nix

 #cloning && build  chainweb-data
 cd /tmp
 git clone https://github.com/kadena-io/chainweb-data
 cd chainweb-data
 nix-build
 mv /tmp/chainweb-data/result/bin/chainweb-data /usr/local/bin/chainweb-data
 sudo chmod 755 /usr/local/bin/chainweb-data
 cd /tmp
 rm -rf nix*

 #starting chainweb-data server
 if [[ -f /usr/local/bin/chainweb-data ]]; then
     node_await
     chainweb-data server --port 8888 --service-host=172.15.0.1 --p2p-host=172.15.0.1 --service-port=30005 --p2p-port=30004 --dbuser=postgres --dbpass=postgres --dbname=postgres 
 fi
