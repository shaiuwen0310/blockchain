#!/bin/bash

export $(cat ./../.env)

function checkFolderExist(){
  if [ -d "${NFS_SHARE_PATH}/crypto-config" ]; then
    echo
    echo "${NFS_SHARE_PATH}/crypto-config(區塊鏈證書資料夾)已存在..."
    exit 1
  fi
}

function checkFileExist(){
  file=$1
  if [ -f ${file} ]; then
    echo "存在${file} 檔案"
  else
    echo "不存在${file} 檔案..."
    exit 1
  fi
}

function createPVC(){
  set +x
  oc create -f fabric-pvc.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "建立PVC失敗..."
    exit 1
  fi
}

function modifySVC(){
  set -x
  cp ./template/fabric-svc-template.yaml ./fabric-svc.yaml
  sed -i "s/CA0_NAME/${CA0_NAME}/g" ./fabric-svc.yaml
  sed -i "s/PEER0_NAME/${PEER0_NAME}/g" ./fabric-svc.yaml
  sed -i "s/PEER1_NAME/${PEER1_NAME}/g" ./fabric-svc.yaml
  sed -i "s/ORDERER_NAME/${ORDERER_NAME}/g" ./fabric-svc.yaml
  sed -i "s/ORDERER2_NAME/${ORDERER2_NAME}/g" ./fabric-svc.yaml
  sed -i "s/ORDERER3_NAME/${ORDERER3_NAME}/g" ./fabric-svc.yaml
  sed -i "s/ORDERER4_NAME/${ORDERER4_NAME}/g" ./fabric-svc.yaml
  sed -i "s/ORDERER5_NAME/${ORDERER5_NAME}/g" ./fabric-svc.yaml
  set +x
}

function createSVC(){
  oc create -f fabric-svc.yaml
  res=$?
  if [ $res -ne 0 ]; then
    echo "建立SVC失敗..."
    exit 1
  fi
}

function createSecret(){
  oc create -f fabric-secret.yaml
  res=$?
  if [ $res -ne 0 ]; then
    echo "建立SECRET失敗..."
    exit 1
  fi
}

function getContainerIP(){
  ordererIP=$(eval echo "$(oc get svc ${ORDERER_NAME} -o yaml | grep clusterIP | awk -F: '{print $2}')")
  orderer2IP=$(eval echo "$(oc get svc ${ORDERER2_NAME} -o yaml | grep clusterIP | awk -F: '{print $2}')")
  orderer3IP=$(eval echo "$(oc get svc ${ORDERER3_NAME} -o yaml | grep clusterIP | awk -F: '{print $2}')")
  orderer4IP=$(eval echo "$(oc get svc ${ORDERER4_NAME} -o yaml | grep clusterIP | awk -F: '{print $2}')")
  orderer5IP=$(eval echo "$(oc get svc ${ORDERER5_NAME} -o yaml | grep clusterIP | awk -F: '{print $2}')")
  peer0IP=$(eval echo "$(oc get svc ${PEER0_NAME} -o yaml | grep clusterIP | awk -F: '{print $2}')")
  peer1IP=$(eval echo "$(oc get svc ${PEER1_NAME} -o yaml | grep clusterIP | awk -F: '{print $2}')")
  ca0IP=$(eval echo "$(oc get svc ${CA0_NAME} -o yaml | grep clusterIP | awk -F: '{print $2}')")
}

function modifyCryptoConfig(){
  set -x
  # 丟到share folder是為了config檔中的路徑
  cp ./template/crypto-config-template.yaml ${NFS_SHARE_PATH}/crypto-config.yaml

  getContainerIP

  sed -i "s/ORDERER_SANS/${ordererIP}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/ORDERER2_SANS/${orderer2IP}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/ORDERER3_SANS/${orderer3IP}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/ORDERER4_SANS/${orderer4IP}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/ORDERER5_SANS/${orderer5IP}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/PEER0_SANS/${peer0IP}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/PEER1_SANS/${peer1IP}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/ORDERER_HOST/${ORDERER_HOST}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/ORDERER2_HOST/${ORDERER2_HOST}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/ORDERER3_HOST/${ORDERER3_HOST}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/ORDERER4_HOST/${ORDERER4_HOST}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/ORDERER5_HOST/${ORDERER5_HOST}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/PEER0_HOST/${PEER0_HOST}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  sed -i "s/PEER1_HOST/${PEER1_HOST}/g" ${NFS_SHARE_PATH}/crypto-config.yaml
  set +x
}

function modifyConfigtx(){
  set -x
  cp ./template/configtx-template.yaml ${NFS_SHARE_PATH}/configtx.yaml

  getContainerIP

  sed -i "s/CA0_NAME/${CA0_NAME}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/PEER0_NAME/${PEER0_NAME}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/PEER1_NAME/${PEER1_NAME}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/ORDERER_NAME/${ORDERER_NAME}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/ORDERER2_NAME/${ORDERER2_NAME}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/ORDERER3_NAME/${ORDERER3_NAME}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/ORDERER4_NAME/${ORDERER4_NAME}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/ORDERER5_NAME/${ORDERER5_NAME}/g" ${NFS_SHARE_PATH}/configtx.yaml

  sed -i "s/ORDERER_HOST/${ordererIP}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/ORDERER2_HOST/${orderer2IP}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/ORDERER3_HOST/${orderer3IP}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/ORDERER4_HOST/${orderer4IP}/g" ${NFS_SHARE_PATH}/configtx.yaml
  sed -i "s/ORDERER5_HOST/${orderer5IP}/g" ${NFS_SHARE_PATH}/configtx.yaml
  res=$?
  set +x
}

function modifyGenfilePod(){
  set -x
  cp ./template/genfile-pod-template.yaml ./genfile-pod.yaml
  sed -i "s/ORDERER_NAME/${ORDERER_NAME}/g" ./genfile-pod.yaml
  sed -i "s/ORDERER2_NAME/${ORDERER2_NAME}/g" ./genfile-pod.yaml
  sed -i "s/ORDERER3_NAME/${ORDERER3_NAME}/g" ./genfile-pod.yaml
  sed -i "s/ORDERER4_NAME/${ORDERER4_NAME}/g" ./genfile-pod.yaml
  sed -i "s/ORDERER5_NAME/${ORDERER5_NAME}/g" ./genfile-pod.yaml
  sed -i "s/OP_ACCOUNT/${OP_ACCOUNT}/g" ./genfile-pod.yaml
  sed -i "s|NFS_SHARE_PATH|${NFS_SHARE_PATH}|g" ./genfile-pod.yaml
  sed -i "s/CHANNEL_NAME/${CHANNEL_NAME}/g" ./genfile-pod.yaml
  set +x
}

function createGenfilePod(){
  oc create -f genfile-pod.yaml
  res=$?
  if [ $res -ne 0 ]; then
    echo
    echo "產生區塊鏈相關檔案失敗..."
    exit 1
  fi
  echo
  echo "等待util pod完成..."
  while [ "${util}" != "Completed" ]
  do
    util=$(eval echo "$(oc get pod | grep util-pod | awk -F' ' '{print $3}')")
    echo "."
    sleep 6
  done
  echo
}

function modifyOrderer(){
  set -x
  cp ./template/orderer-deployment-template.yaml ./orderer-deployment.yaml
  sed -i "s/OP_ACCOUNT/${OP_ACCOUNT}/g" ./orderer-deployment.yaml
  sed -i "s|TIMEZONE|${TIMEZONE}|g" ./orderer-deployment.yaml
  set +x
}

function modifypeer(){
  set -x
  cp ./template/peer-deployment-template.yaml ./peer-deployment.yaml
  sed -i "s/OP_ACCOUNT/${OP_ACCOUNT}/g" ./peer-deployment.yaml
  sed -i "s/PEER0_NAME/${PEER0_NAME}/g" ./peer-deployment.yaml
  sed -i "s/PEER1_NAME/${PEER1_NAME}/g" ./peer-deployment.yaml
  sed -i "s|TIMEZONE|${TIMEZONE}|g" ./peer-deployment.yaml
  set +x
}

function modifyCliPod(){
  set -x
  cp ./template/cli-pod-template.yaml ./cli-pod.yaml
  sed -i "s/PEER0_NAME/${PEER0_NAME}/g" ./cli-pod.yaml
  sed -i "s/OP_ACCOUNT/${OP_ACCOUNT}/g" ./cli-pod.yaml
  sed -i "s|TIMEZONE|${TIMEZONE}|g" ./cli-pod.yaml
  set +x
}

function waitCryptoConfig(){
  echo "等待crypto-config資料夾產生..."
  echo
  while [ true ]
  do
    if [ -d "${NFS_SHARE_PATH}/crypto-config" ]; then
      echo "產生crypto-config資料夾成功..."
      break
    fi
  done
  echo
}

function modifyCA(){
  set -x
  cp ./template/ca-deployment-template.yaml ./ca-deployment.yaml
  privateKey=$(cd ${NFS_SHARE_PATH}/crypto-config/peerOrganizations/org1.example.com/ca && ls *_sk)
  sed -i "s/BYFN_CA1_PRIVATE_KEY/${privateKey}/g" ./ca-deployment.yaml
  sed -i "s/OP_ACCOUNT/${OP_ACCOUNT}/g" ./ca-deployment.yaml
  sed -i "s/CA0_HOST/${CA0_HOST}/g" ./ca-deployment.yaml
  sed -i "s|TIMEZONE|${TIMEZONE}|g" ./ca-deployment.yaml
  # sed -i "s/CA_ACCOUNT/${CA_ACCOUNT}/g" ./ca-deployment.yaml
  # sed -i "s/CA_PWD/${CA_PWD}/g" ./ca-deployment.yaml
  set +x
}

function modifyUpnode(){
  set -x
  cp ./template/upnode-template.sh ./upnode.sh
  sed -i "s/PEER0_NAME/${PEER0_NAME}/g" ./upnode.sh
  sed -i "s/PEER1_NAME/${PEER1_NAME}/g" ./upnode.sh
  sed -i "s/ORDERER_NAME/${ORDERER_NAME}/g" ./upnode.sh
  sed -i "s/channel_name/${CHANNEL_NAME}/g" ./upnode.sh
  sed -i "s|NFS_SHARE_PATH|${NFS_SHARE_PATH}|g" ./upnode.sh
  set +x
}

function modifyNewCC(){
  set -x
  cp ./template/newCC-template.sh ./newCC.sh
  sed -i "s|NFS_SHARE_PATH|${NFS_SHARE_PATH}|g" ./newCC.sh
  set +x
}

function modifyUpgradeCC(){
  set -x
  cp ./template/upgradeCC-template.sh ./upgradeCC.sh
  sed -i "s|NFS_SHARE_PATH|${NFS_SHARE_PATH}|g" ./upgradeCC.sh
  set +x
}

function modifyRemainSVC(){
  set -x
  cp ./template/remain-svc-template.yaml ./remain-svc.yaml

  getContainerIP

  sed -i "s/CA0_NAME/${CA0_NAME}/g" ./remain-svc.yaml
  sed -i "s/PEER0_NAME/${PEER0_NAME}/g" ./remain-svc.yaml
  sed -i "s/PEER1_NAME/${PEER1_NAME}/g" ./remain-svc.yaml
  sed -i "s/ORDERER_NAME/${ORDERER_NAME}/g" ./remain-svc.yaml
  sed -i "s/ORDERER2_NAME/${ORDERER2_NAME}/g" ./remain-svc.yaml
  sed -i "s/ORDERER3_NAME/${ORDERER3_NAME}/g" ./remain-svc.yaml
  sed -i "s/ORDERER4_NAME/${ORDERER4_NAME}/g" ./remain-svc.yaml
  sed -i "s/ORDERER5_NAME/${ORDERER5_NAME}/g" ./remain-svc.yaml

  sed -i "s/ORDERER_SVC_IP/${ordererIP}/g" ./remain-svc.yaml
  sed -i "s/ORDERER2_SVC_IP/${orderer2IP}/g" ./remain-svc.yaml
  sed -i "s/ORDERER3_SVC_IP/${orderer3IP}/g" ./remain-svc.yaml
  sed -i "s/ORDERER4_SVC_IP/${orderer4IP}/g" ./remain-svc.yaml
  sed -i "s/ORDERER5_SVC_IP/${orderer5IP}/g" ./remain-svc.yaml
  sed -i "s/PEER0_SVC_IP/${peer0IP}/g" ./remain-svc.yaml
  sed -i "s/PEER1_SVC_IP/${peer1IP}/g" ./remain-svc.yaml
  sed -i "s/CA0_SVC_IP/${ca0IP}/g" ./remain-svc.yaml
  res=$?
  set +x
}

checkFolderExist
checkFileExist "fabric-pvc.yaml"
checkFileExist "template/fabric-svc-template.yaml"
checkFileExist "template/crypto-config-template.yaml"
checkFileExist "template/configtx-template.yaml"
checkFileExist "template/genfile-pod-template.yaml"
checkFileExist "template/orderer-deployment-template.yaml"
checkFileExist "template/peer-deployment-template.yaml"
checkFileExist "template/cli-pod-template.yaml"
checkFileExist "template/ca-deployment-template.yaml"
checkFileExist "template/upnode-template.sh"
checkFileExist "template/newCC-template.sh"
checkFileExist "template/upgradeCC-template.sh"
checkFileExist "template/remain-svc-template.yaml"

createPVC
modifySVC
createSVC
createSecret
modifyCryptoConfig
modifyConfigtx
modifyGenfilePod
createGenfilePod
modifyOrderer
modifypeer
modifyCliPod
waitCryptoConfig
modifyCA
modifyUpnode
modifyNewCC
modifyUpgradeCC
modifyRemainSVC

