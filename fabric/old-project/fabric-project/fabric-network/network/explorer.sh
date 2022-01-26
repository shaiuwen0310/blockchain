#!/bin/bash

cd /home/judy/go/src/github.com/hyperledger/myfabric-project/project-raft/fabric-network/network
# SOURCE="${BASH_SOURCE[0]}"
# # While $SOURCE is a symlink, resolve it
# while [ -h "$SOURCE" ]; do
#     DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
#     SOURCE="$( readlink "$SOURCE" )"
#     # If $SOURCE was a relative symlink (so no "/" as prefix, need to resolve it relative to the symlink base directory
#     [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
# done
# DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
# echo "$DIR"
# cd $DIR

function upexplorer() {
  cp ./explorer/net/connection-profile/blockchain-scanfile-template.json ./explorer/net/connection-profile/blockchain-scanfile.json
  export PEER_USER_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/ && ls *_sk)
  channelname=$(tail -n 1 ./genlist)
  sed -i "s/PEER_USER_PRIVATE_KEY/${PEER_USER_PRIVATE_KEY}/g" ./explorer/net/connection-profile/blockchain-scanfile.json
  sed -i "s/CHANNEL_NAME/${channelname}/g" ./explorer/net/connection-profile/blockchain-scanfile.json

  docker-compose -f docker-compose-explorer.yaml up -d 2>&1
}

function downexplorer() {
  docker-compose -f docker-compose-explorer.yaml down

  rm -rf ./explorer/net/connection-profile/blockchain-scanfile.json
}

function restartexplorer(){
  cp ./explorer/net/connection-profile/blockchain-scanfile-template.json ./explorer/net/connection-profile/blockchain-scanfile.json
  export PEER_USER_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/ && ls *_sk)
  channelname=$(tail -n 1 ./genlist)
  sed -i "s/PEER_USER_PRIVATE_KEY/${PEER_USER_PRIVATE_KEY}/g" ./explorer/net/connection-profile/blockchain-scanfile.json
  sed -i "s/CHANNEL_NAME/${channelname}/g" ./explorer/net/connection-profile/blockchain-scanfile.json

  docker-compose -f docker-compose-explorer.yaml up -d 2>&1
}

MODE=$1

if [ "${MODE}" == "up" ]; then
  upexplorer
elif [ "${MODE}" == "down" ]; then
  downexplorer
elif [ "${MODE}" == "restart" ]; then
  restartexplorer
else
  echo "wrong mode to operate explorer"
  exit 1
fi