#!/bin/bash

export $(cat .env)

# 
# 功能
#   用於重新建立已有的peer節點
# 


# Ask user for confirmation to proceed
function askProceed() {
  read -p "是否要重起${NODE}？是否已'刪除'容器、資料存放路徑？ [Y/N] " ans
  echo
  case "$ans" in
  y | Y)
    echo "繼續往下執行..."
    ;;
  n | N)
    echo "離開...請確認批次中的【預設參數】是否正確..."
    echo
    exit 1
    ;;
  *)
    echo "不合法回覆..."
    askProceed
    ;;
  esac
}

# 啟動節點
function startPeer() {
  docker-compose -f ${COMPOSE_FILE} up -d ${NODE}
  echo "等待peer啟動......"
  sleep 16 
}

# peer加入channel，使peer接收在channel上的資訊
function joinChannel(){
  echo
  echo "將peer加入channel中..."

  FILENAME=genlist
  for channel_name in `cat $FILENAME`
  do
    docker exec cli scripts/script.sh joinchannel ${NODE} "" ${channel_name} ""
  done
}

# 找這個peer對應的chaincode容器，抓取其chaincode版本號，並安裝所有版本
function chaincodeInstall(){
  # 智能合約版本
  vers=$(docker ps -a | grep "dev-${NODE}-${CC}cc-" | cut -d"-" -f 4)
  # 智能合約版本數量
  END=$(docker ps -a | grep "dev-${NODE}-${CC}cc-" | cut -d"-" -f 4 | wc -l)

  for i in $(seq 1 $END);
  do
    version=$(echo $vers | cut -d" " -f ${i})
    docker exec cli scripts/script.sh install ${NODE} ${CC} "" ${version}
  done
}

function Check(){
  # 抓peer簡稱
  name=$(echo ${NODE} | cut -d"." -f 1)
  # 抓peer資料路徑
  path=$(cat .env | grep ${name} | cut -d"=" -f 2)
  echo "資料存放路徑: ${path}"

  # 抓peer容器id
  container_id=$(docker ps -aqf "name=${NODE}$")

  if [ ! -z "$container_id" ]; then
    echo "請先確認是否已 '刪除' ${NODE}(conatiner id: $container_id)的容器..."
    exit 1
  fi

  if [ -d "${path}" ]; then
    echo "請先確認是否已 '刪除' ${NODE}(conatiner id: $container_id)存放資料的路徑..."
    exit 1
  fi

}



# 預設參數
COMPOSE_FILE=docker-compose-peer.yaml
NODE=peer0.org1.example.com
CC=iotdata


askProceed

Check
startPeer
joinChannel
chaincodeInstall