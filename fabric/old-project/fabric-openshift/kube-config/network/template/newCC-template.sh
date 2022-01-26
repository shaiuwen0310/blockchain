#!/bin/bash

function allYouCanEat(){
  ccname=$1
  FILENAME=NFS_SHARE_PATH/peerlist
  for i in `cat $FILENAME`
  do
    oc exec cli-pod scripts/script.sh install $i ${ccname}
    sleep 3
  done
}

function NewChaincodeInstall(){
  ccname=$1
  if [ -f "NFS_SHARE_PATH/chaincode/rcc" ]; then
    echo "add a new chaincode ${ccname}..."
    allYouCanEat ${ccname}
  else
    echo "there is no rcc..."
    exit 1
  fi
}

function NewChaincodeInstantiate(){
  ccname=$1
  assignPeer=$(head -1 NFS_SHARE_PATH/peerlist)
  oc exec cli-pod scripts/script.sh instantiate ${assignPeer} ${ccname}
  res=$?
  if [ $res -ne 0 ]; then
    echo
    echo "Failed to instantiate chaincode..."
    echo
    exit 1
  fi
  echo "${ccname}" >> NFS_SHARE_PATH/chaincode/rcc
}

if [ ! -d "NFS_SHARE_PATH/crypto-config" ]; then
  echo "check if the network is running....."
  exit 1
fi

read -p "請輸入要新增的合約名稱(資料夾名稱):" ans
NewChaincodeInstall $ans
NewChaincodeInstantiate $ans
