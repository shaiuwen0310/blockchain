#!/bin/bash

function allYouCanEat(){
  ccname=$1
  version=$2
  FILENAME=peerlist
  for i in `cat $FILENAME`
  do
    docker exec cli scripts/upgrade.sh install $i ${ccname} ${version}
    sleep 3
  done
}

function chaincodeInstall(){
  ccname=$1
  version=$2
  echo "upgrade chaincode ${ccname}..."
  allYouCanEat ${ccname} ${version}
}

function chaincodeUpgrade(){
  ccname=$1
  version=$2
  assignPeer=$(head -1 ./peerlist)
  docker exec cli scripts/upgrade.sh upgrade ${assignPeer} ${ccname} ${version}
}

if [ ! -d "crypto-config" ]; then
  echo "check if the network is running....."
  exit 1
fi

read -p "請輸入要升級的合約名稱(資料夾名稱):" ans
read -p "請輸入版本號(eg. 2.0):" ver
chaincodeInstall $ans $ver
chaincodeUpgrade $ans $ver
