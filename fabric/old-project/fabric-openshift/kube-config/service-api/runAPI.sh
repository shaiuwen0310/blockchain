#!/bin/bash

export $(cat ./../.env)

function checkFileExist(){
  file=$1
  if [ -f ${file} ]; then
    echo "存在${file} 檔案"
  else
    echo "不存在${file} 檔案..."
    exit 1
  fi
}

function modifyAPI(){
  cp ./api-deployment-template.yaml ./api-deployment.yaml
  sed -i "s/OP_ACCOUNT/${OP_ACCOUNT}/g" ./api-deployment.yaml
  sed -i "s/PROJ_NAME/${PROJ_NAME}/g" ./api-deployment.yaml
  sed -i "s|TIMEZONE|${TIMEZONE}|g" ./api-deployment.yaml
}

function modifyWalletId(){
  cp ./genfile-pod-template.yaml ./genfile-pod.yaml
  SERVICE_IP=$(eval echo "$(oc get svc ${NODE_SERVICE_SVC} -o yaml | grep clusterIP | awk -F: '{print $2}')")
  SERVICE_PORT=$(eval echo "$(oc get svc ${NODE_SERVICE_SVC} -o yaml | grep port: | awk -F: '{print $2}')")
  sed -i "s/SERVICE_IP/${SERVICE_IP}/g" ./genfile-pod.yaml
  sed -i "s/SERVICE_PORT/${SERVICE_PORT}/g" ./genfile-pod.yaml
  sed -i "s/CHAINCODES/${CHAINCODES}/g" ./genfile-pod.yaml
  sed -i "s/OP_ACCOUNT/${OP_ACCOUNT}/g" ./genfile-pod.yaml
  sed -i "s|NFS_SHARE_PATH|${NFS_SHARE_PATH}|g" ./genfile-pod.yaml
}

function createSVC(){
  set +x
  oc create -f api-svc.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "建立SVC失敗..."
    exit 1
  fi
}

function setConfig(){
  caOrg1Key=`basename ${NFS_SHARE_PATH}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*`

  cp ./gateway/networkConnection-template.yaml ./gateway/networkConnection.yaml

  sed -i "s/CHANNEL_NAME/${CHANNEL_NAME}/g" ./gateway/networkConnection.yaml
  sed -i "s/CA_ORG1_KEY/${caOrg1Key}/g" ./gateway/networkConnection.yaml

  sed -i "s/ORDERER_NAME/${ORDERER_NAME}/g" ./gateway/networkConnection.yaml
  sed -i "s/ORDERER2_NAME/${ORDERER2_NAME}/g" ./gateway/networkConnection.yaml
  sed -i "s/ORDERER3_NAME/${ORDERER3_NAME}/g" ./gateway/networkConnection.yaml
  sed -i "s/ORDERER4_NAME/${ORDERER4_NAME}/g" ./gateway/networkConnection.yaml
  sed -i "s/ORDERER5_NAME/${ORDERER5_NAME}/g" ./gateway/networkConnection.yaml
  sed -i "s/PEER0_NAME/${PEER0_NAME}/g" ./gateway/networkConnection.yaml
  sed -i "s/PEER1_NAME/${PEER1_NAME}/g" ./gateway/networkConnection.yaml
  sed -i "s/CA0_NAME/${CA0_NAME}/g" ./gateway/networkConnection.yaml

  sed -i "s/CA0_HOST/${CA0_HOST}/g" ./gateway/networkConnection.yaml
  sed -i "s/ORDERER_HOST/${ORDERER_HOST}/g" ./gateway/networkConnection.yaml
  sed -i "s/ORDERER2_HOST/${ORDERER2_HOST}/g" ./gateway/networkConnection.yaml
  sed -i "s/ORDERER3_HOST/${ORDERER3_HOST}/g" ./gateway/networkConnection.yaml
  sed -i "s/ORDERER4_HOST/${ORDERER4_HOST}/g" ./gateway/networkConnection.yaml
  sed -i "s/ORDERER5_HOST/${ORDERER5_HOST}/g" ./gateway/networkConnection.yaml
  sed -i "s/PEER0_HOST/${PEER0_HOST}/g" ./gateway/networkConnection.yaml
  sed -i "s/PEER1_HOST/${PEER1_HOST}/g" ./gateway/networkConnection.yaml

  sed -i "s/CA_ACCOUNT/${CA_ACCOUNT}/g" ./gateway/networkConnection.yaml
  sed -i "s/CA_PWD/${CA_PWD}/g" ./gateway/networkConnection.yaml

  # 把設定檔都複製到nfs路徑中
  cp -r ./gateway/ ${NFS_SHARE_PATH}
}

function createAPI(){
  oc create -f api-deployment.yaml
  res=$?
  if [ $res -ne 0 ]; then
    echo
    echo "啟動api服務失敗..."
    exit 1
  fi
  echo
  echo "等待api服務啟動完成..."
  while [ "${ezscanfile}" != "1" -o "${traceability}" != "1" ]
  do
    ezscanfile=$(eval echo "$(oc get replicationcontroller | grep ezscanfile-deploy | awk -F' ' '{print $4}')")
    # scanfile=$(eval echo "$(oc get replicationcontroller | grep scanfile-deploy | awk -F' ' '{print $4}')")
    traceability=$(eval echo "$(oc get replicationcontroller | grep traceability-deploy | awk -F' ' '{print $4}')")
    echo "."
    sleep 10
  done
  echo
  sleep 6
  echo "api服務啟動完成..."

}

function createWalletId(){
  oc create -f genfile-pod.yaml
  res=$?
  if [ $res -ne 0 ]; then
    echo
    echo "新增wallet id失敗..."
    exit 1
  fi
  echo
  echo "等待建立wallet id完成..."
  while [ "${util}" != "Completed" ]
  do
    util=$(eval echo "$(oc get pod | grep genid-pod | awk -F' ' '{print $3}')")
    echo "."
    sleep 6
  done
  echo

}

# # 對外使用ip:port，故不使用expose
# echo "create svc expose..."
# oc expose svc scanfile-svc
# oc get route

checkFileExist "api-svc.yaml"
checkFileExist "gateway/networkConnection-template.yaml"
checkFileExist "api-deployment-template.yaml"

createSVC
modifyAPI
modifyWalletId
setConfig
createAPI
createWalletId


