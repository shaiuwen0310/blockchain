#!/bin/bash

# 啟動節點
function startNode() {
  echo "====== start the fabric network ======"
  echo
  COMPOSE_FILES="-f ${COMPOSE_FILE} -f ${COMPOSE_FILE_CA} -f ${COMPOSE_FILE_RAFT2} -f ${COMPOSE_FILE_COUCH}"
  export BYFN_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/ca && ls *_sk)

  docker-compose ${COMPOSE_FILES} up -d 2>&1
  docker ps -a
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start network"
    exit 1
  fi

  sleep 1
  echo "Sleeping 15s to allow etcdraft cluster to complete booting"
  sleep 14

  # 紀錄peer容器名稱
  peerlist=$(docker ps --format '{{.Names}}' | grep 'peer')
  echo "${peerlist}" > peerlist
  echo "====== end the fabric network ======"
  echo
}

# 建立channel並peer加入channel
function createLedger(){
  channelname=$(tail -n 1 ./genlist)
  echo "CHANNEL_NAME=${channelname}" > ./scripts/channel.sh
  # 建立channel
  docker exec cli scripts/script.sh createchannel
  sleep 3
  # peer加入channel
  FILENAME=peerlist
  for i in `cat $FILENAME`
  do
    docker exec cli scripts/script.sh joinchannel $i
    sleep 3
  done
}

function allYouCanEat(){
  ccname=$1
  FILENAME=peerlist
  for i in `cat $FILENAME`
  do
    docker exec cli scripts/script.sh install $i ${ccname}
    sleep 3
  done
}

function ChaincodeInstall(){
  if [ ! -f "./../chaincode/rcc" ]; then
    echo "there is no cc be installed..."
    echo
    dir=$(ls -l ./../chaincode/ | awk '/^d/ {print $NF}')
    for i in $dir
    do
      allYouCanEat $i
    done
  fi
}

function ChaincodeInstantiate(){
  dir=$(ls -l ./../chaincode/ | awk '/^d/ {print $NF}')
  assignPeer=$(head -1 ./peerlist)
  for i in ${dir}
  do
    docker exec cli scripts/script.sh instantiate ${assignPeer} ${i}
    sleep 3
    echo "${i}" >> ./../chaincode/rcc
  done
}

# test ! -e crypto-config && echo "crypto-config does not exist" || exit 0
if [ ! -d "crypto-config" ]; then
  echo "run generate.sh first"
  exit 1
fi

COMPOSE_FILE=docker-compose-cli.yaml
#
COMPOSE_FILE_COUCH=docker-compose-couch.yaml
# two additional etcd/raft orderers
COMPOSE_FILE_RAFT2=docker-compose-etcdraft2.yaml
# certificate authorities compose file
COMPOSE_FILE_CA=docker-compose-ca.yaml





startNode
createLedger
ChaincodeInstall
ChaincodeInstantiate
