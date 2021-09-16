#!/bin/bash

export $(cat .env)

# 
# 用於重新建立已有的peer節點
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
}

# 建立channel並peer都加入channel，使peer都可以接收在這個channel上的資訊
function joinLedger(){  
  echo
  echo "將peer重新加入channel中..."
  
  # 每個帳本{0 1 2 ...}都有2個peer，一個是peer0 或peer1 或peer2...，另一個是peer0+帳本個數 或peer1+帳本個數 或peer2+帳本個數...
  # 用peer0 或peer1 或peer2...找出是第幾個帳本(因為與peer一樣編號)
  # 
  # 共有幾個帳本
  n=$(wc -l genlist | cut -d" " -f 1)
  # 第幾個peer
  x=$(echo $NODE | cut -d"." -f 1 | cut -d"r" -f 2)
  if [ "$x" -gt "$n" ]; then
      # 第幾個帳本
      num=$(($x-$n))
  elif [ "$x" -le "$n" ]; then
      num=$x
  fi

  # 帳本名稱
  channelname=$(grep "$(($num))$" genlist)
  docker exec cli scripts/script.sh joinchannel ${NODE} "" ${channelname} ""

}

# 找這個peer對應的chaincode容器，抓取其chaincode版本號，並安裝所有版本
function chaincodeInstall(){
  # 智能合約版本
  vers=$(docker ps -a | grep "dev-${NODE}-iotdatacc-" | cut -d"-" -f 4)
  # 智能合約版本數量
  END=$(docker ps -a | grep "dev-${NODE}-iotdatacc-" | cut -d"-" -f 4 | wc -l)

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
  echo "${path}"

  if [ -d "${path}" ]; then
    echo "請先確認是否已'刪除'${NODE}的容器、資料存放路徑..."
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
joinLedger
chaincodeInstall