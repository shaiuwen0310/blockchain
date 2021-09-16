#!/bin/bash

# 
# 功能
#   新增合約到每個peer及其所在的帳本(channel)上
# 

function installing(){
  ccname=$1
  FILENAME=peerlist
  for i in `cat $FILENAME`
  do
    echo
    # 第一次安裝合約 都是1.0
    docker exec cli scripts/script.sh install $i ${ccname} "" "1.0"
    sleep 3
  done
}

function NewChaincodeInstall(){
  ccname=$1
  if [ -f "./../chaincode/rcc" ]; then
    echo "新增新合約 '${ccname}'..."
    installing ${ccname}
  fi
}

function NewChaincodeInstantiate(){
  ccname=$1
  echo

  assignPeer=$(head -1 ./peerlist)
  echo
  echo "chaincode實例化..."
    FILENAME=genlist
    for channel_name in `cat $FILENAME`
    do
      docker exec cli scripts/script.sh instantiate ${assignPeer} ${ccname} ${channel_name} "1.0"
      sleep 3
    done

    echo "${ccname}" >> ./../chaincode/rcc
}

if [ ! -d "crypto-config" ]; then
  echo "check if the network is running....."
  exit 1
fi

read -p "請輸入要新增的合約名稱(資料夾名稱):" ans
NewChaincodeInstall $ans
NewChaincodeInstantiate $ans
