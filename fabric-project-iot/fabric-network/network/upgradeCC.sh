#!/bin/bash

function installing(){
  ccname=$1
  version=$2
  FILENAME=peerlist
  for i in `cat $FILENAME`
  do
    echo
    docker exec cli scripts/upgrade.sh install $i ${ccname} ${version} ""
    sleep 3
  done
}

# 將修改後的智能合約安裝在所有peer上
function chaincodeInstall(){
  ccname=$1
  version=$2
  echo
  echo "upgrade chaincode ${ccname}..."
  installing ${ccname} ${version}
}

function chaincodeUpgrade(){
  ccname=$1
  version=$2
  echo
  
  # 帳本個數
  FILENAME=genlist
  for channel_name in `cat $FILENAME`
  do
    assignPeer=$(head -1 ./peerlist)

    docker exec cli scripts/upgrade.sh upgrade ${assignPeer} ${ccname} ${version} ${channel_name}
    sleep 3
  done
}

if [ ! -d "crypto-config" ]; then
  echo "check if the network is running....."
  exit 1
fi

read -p "請輸入要升級的合約名稱(資料夾名稱):" ans
read -p "請輸入版本號(eg. 2.0):" ver
chaincodeInstall $ans $ver
chaincodeUpgrade $ans $ver
