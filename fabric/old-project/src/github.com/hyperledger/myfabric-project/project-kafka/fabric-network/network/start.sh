#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.

# ./start.sh 第一次執行
# ./start.sh -a yourchannel 增加一個合約

# 啟動節點
function startNode() {
  echo "====== start the fabric network ======"
  echo
  docker-compose -f docker-zookeeper.yaml up -d
  sleep 6
  docker-compose -f docker-kafka.yaml up -d
  sleep 6
  docker-compose -f docker-orderer.yaml up -d
  sleep 3
  docker-compose -f docker-couchdb.yaml up -d
  sleep 3
  docker-compose -f docker-peer.yaml up -d
  sleep 3
  docker-compose -f docker-ca.yaml up -d
  sleep 3
  docker-compose -f docker-cli.yaml up -d
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
    echo "all you can install but not eat..."
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

# function aNewChaincodeInstall(){
#   ccname=$1
#   if [ -f "./../chaincode/rcc" ]; then
#     echo "add a new chaincode ${ccname}..."
#     allYouCanEat ${ccname}
#   fi
# }

# function aNewChaincodeInstantiate(){
#   ccname=$1
#   assignPeer=$(head -1 ./peerlist)
#   docker exec cli scripts/script.sh instantiate ${assignPeer} ${ccname}
#   echo "${ccname}" >> ./../chaincode/rcc
# }

if [ ! -d "crypto-config" ]; then
  echo "run generate.sh first"
  exit 1
fi

# while getopts "a:" opt; do
#   case "$opt" in
#    a)
#     echo "install a new chaincode $OPTARG"
#     aNewChaincodeInstall $OPTARG
#     aNewChaincodeInstantiate $OPTARG
#     exit 0
#     ;;
#   esac
# done

startNode
createLedger
ChaincodeInstall
ChaincodeInstantiate
