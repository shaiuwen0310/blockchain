#!/bin/bash

# 啟動節點
function startNode() {
  echo "====== start the fabric network ======"
  echo

  oc create -f orderer-deployment.yaml
  echo
  echo "Waiting all orderers are in the running state......"
  echo
  while [ "${orderer}" != "1" -o "${orderer2}" != "1" -o "${orderer3}" != "1" -o "${orderer4}" != "1" -o "${orderer5}" != "1" ]
  do
    orderer=$(eval echo "$(oc get replicationcontroller | grep orderer-deploy | awk -F' ' '{print $4}')")
    orderer2=$(eval echo "$(oc get replicationcontroller | grep orderer2-deploy | awk -F' ' '{print $4}')")
    orderer3=$(eval echo "$(oc get replicationcontroller | grep orderer3-deploy | awk -F' ' '{print $4}')")
    orderer4=$(eval echo "$(oc get replicationcontroller | grep orderer4-deploy | awk -F' ' '{print $4}')")
    orderer5=$(eval echo "$(oc get replicationcontroller | grep orderer5-deploy | awk -F' ' '{print $4}')")
  done
  echo
  sleep 10
  echo "All orderers are CURRENT 1......"
  echo

  oc create -f peer-deployment.yaml
  echo
  echo "Waiting all peers are in the running state......"
  echo
  while [ "${peer0}" != "1" -o "${peer1}" != "1" ]
  do
    peer0=$(eval echo "$(oc get replicationcontroller | grep peer0-deploy | awk -F' ' '{print $4}')")
    peer1=$(eval echo "$(oc get replicationcontroller | grep peer1-deploy | awk -F' ' '{print $4}')")
  done
  echo
  echo "All peers are CURRENT 1......"
  echo

  oc create -f ca-deployment.yaml
  oc create -f cli-pod.yaml
  while [ "${ca0}" != "1" -o "${cli}" != "Running" ]
  do
    ca0=$(eval echo "$(oc get replicationcontroller | grep ca0-deploy | awk -F' ' '{print $4}')")
    cli=$(eval echo "$(oc get pod | grep cli-pod | awk -F' ' '{print $3}')")
  done

  # 紀錄peer容器名稱
  peer0IP=$(eval echo "$(kubectl get svc PEER0_NAME -o yaml | grep clusterIP | awk -F: '{print $2}')")
  peer1IP=$(eval echo "$(kubectl get svc PEER1_NAME -o yaml | grep clusterIP | awk -F: '{print $2}')")
  peer0PORT=$(eval echo "$(kubectl get svc PEER0_NAME -o yaml | grep port: | awk -F: '{print $2}')")
  peer1PORT=$(eval echo "$(kubectl get svc PEER1_NAME -o yaml | grep port: | awk -F: '{print $2}')")
  peer0=${peer0IP}':'${peer0PORT}
  peer1=${peer1IP}':'${peer1PORT}
  echo "${peer0}" > NFS_SHARE_PATH/peerlist
  echo "${peer1}" >> NFS_SHARE_PATH/peerlist

  echo
  echo "====== end the fabric network ======"
  echo
}

# 建立channel並peer加入channel
function createLedger(){
  echo "CHANNEL_NAME=channel_name" > NFS_SHARE_PATH/scripts/env.sh
  sleep 1
  ordererIP=$(eval echo "$(kubectl get svc ORDERER_NAME -o yaml | grep clusterIP | awk -F: '{print $2}')")
  ordererPORT=$(eval echo "$(kubectl get svc ORDERER_NAME -o yaml | grep port: | awk -F: '{print $2}')")
  orderer=${ordererIP}':'${ordererPORT}
  echo "CONNECT_ORDERER=${orderer}" >> NFS_SHARE_PATH/scripts/env.sh

  sleep 1
  # 建立channel
  oc exec cli-pod scripts/script.sh createchannel
  sleep 3
  # peer加入channel
  FILENAME=NFS_SHARE_PATH/peerlist
  for i in `cat $FILENAME`
  do
    oc exec cli-pod scripts/script.sh joinchannel $i
    sleep 3
  done
}

function allYouCanEat(){
  ccname=$1
  FILENAME=NFS_SHARE_PATH/peerlist
  for i in `cat $FILENAME`
  do
    oc exec cli-pod scripts/script.sh install $i ${ccname}
    sleep 3
  done
}

function ChaincodeInstall(){
  if [ ! -f "NFS_SHARE_PATH/chaincode/rcc" ]; then
    echo
    echo "there is no cc be installed...all you can install..."
    echo
    dir=$(ls -l NFS_SHARE_PATH/chaincode | awk '/^d/ {print $NF}')
    for i in $dir
    do
      allYouCanEat $i
    done
  fi
}

function ChaincodeInstantiate(){
  dir=$(ls -l NFS_SHARE_PATH/chaincode/ | awk '/^d/ {print $NF}')
  assignPeer=$(head -1 NFS_SHARE_PATH/peerlist)
  for i in ${dir}
  do
    oc exec cli-pod scripts/script.sh instantiate ${assignPeer} ${i}
    res=$?
    if [ $res -ne 0 ]; then
      echo
      echo "Failed to instantiate chaincode..."
      echo
      exit 1
    fi
    echo
    echo "${i}" >> NFS_SHARE_PATH/chaincode/rcc
    sleep 3
  done
}

startNode
createLedger
ChaincodeInstall
ChaincodeInstantiate