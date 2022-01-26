#!/bin/bash

function allYouCanEat(){
  ccname=$1
  version=$2
  FILENAME=NFS_SHARE_PATH/peerlist
  for i in `cat $FILENAME`
  do
    oc exec cli-pod scripts/upgrade.sh install $i ${ccname} ${version}
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
  assignPeer=$(head -1 NFS_SHARE_PATH/peerlist)
  oc exec cli-pod scripts/upgrade.sh upgrade ${assignPeer} ${ccname} ${version}
}



if [ ! -d "NFS_SHARE_PATH/crypto-config" ]; then
  echo "check if the network is running....."
  exit 1
fi

read -p "請輸入要升級的合約名稱(資料夾名稱):" ans
read -p "請輸入版本號(eg. 2.0):" ver
chaincodeInstall $ans $ver
chaincodeUpgrade $ans $ver
