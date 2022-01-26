#!/bin/bash

function allYouCanEat(){
  ccname=$1
  FILENAME=peerlist
  for i in `cat $FILENAME`
  do
    docker exec cli scripts/script.sh install $i ${ccname}
    sleep 3
  done
}

function NewChaincodeInstall(){
  ccname=$1
  if [ -f "./../chaincode/rcc" ]; then
    echo "add a new chaincode ${ccname}..."
    allYouCanEat ${ccname}
  fi
}

function NewChaincodeInstantiate(){
  ccname=$1
  assignPeer=$(head -1 ./peerlist)
  docker exec cli scripts/script.sh instantiate ${assignPeer} ${ccname}
  echo "${ccname}" >> ./../chaincode/rcc
}

if [ ! -d "crypto-config" ]; then
  echo "check if the network is running....."
  exit 1
fi

read -p "請輸入要新增的合約名稱(資料夾名稱):" ans
NewChaincodeInstall $ans
NewChaincodeInstantiate $ans
