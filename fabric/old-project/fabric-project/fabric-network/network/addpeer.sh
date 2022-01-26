#!/bin/bash

function askProceed() {
  read -p "請確定設定檔已更新? [Y/N] " ans
  case "$ans" in
  y | Y)
    echo "proceeding ..."
    ;;
  n | N)
    echo "exiting..."
    echo
    echo "對docker-compose-cli-new.yaml、docker-compose-couch-new.yaml、crypto-config.yaml、EXTEND_PEER進行調整"
    exit 1
    ;;
  *)
    echo
    echo "對docker-compose-cli-new.yaml、docker-compose-couch-new.yaml、crypto-config.yaml、EXTEND_PEER進行調整"
    echo
    askProceed
    ;;
  esac
}

function genCryptoConfig(){
  cryptogen extend --config=./crypto-config.yaml
}

# 啟動節點
function startNode() {
  echo "====== start the fabric network ======"
  echo
  COMPOSE_FILES="-f ${COMPOSE_FILE} -f ${COMPOSE_FILE_COUCH}"

  docker-compose ${COMPOSE_FILES} up -d 2>&1
  docker ps -a
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start network"
    exit 1
  fi

  sleep 6

  echo "====== end the fabric network ======"
  echo
}

# 建立channel並peer加入channel
function createLedger(){
  # peer加入channel
    docker exec cli scripts/script.sh joinchannel ${EXTEND_PEER}
    sleep 3
}

function allYouCanEat(){
  ccname=$1
  docker exec cli scripts/script.sh install ${EXTEND_PEER} ${ccname}
  sleep 3
}

function ChaincodeInstall(){
    dir=$(ls -l ./../chaincode/ | awk '/^d/ {print $NF}')
    for i in $dir
    do
      allYouCanEat $i
    done
}

# test ! -e crypto-config && echo "crypto-config does not exist" || exit 0
if [ ! -d "crypto-config" ]; then
  echo "你需要先有區塊鏈平台，才可以新增加一個peer..."
  exit 1
fi

ck=$(cat crypto-config.yaml | grep 'Count: 2')
if [[ -n "${ck}" ]]; then
  echo "please check crypto-config.yaml...Template.Count cannot be 2..."
  exit 1
fi


COMPOSE_FILE=docker-compose-cli-new.yaml
#
COMPOSE_FILE_COUCH=docker-compose-couch-new.yaml
#
EXTEND_PEER=peer2.org1.example.com


askProceed

genCryptoConfig
startNode
createLedger
ChaincodeInstall

