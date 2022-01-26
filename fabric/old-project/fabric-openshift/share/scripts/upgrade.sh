#!/bin/bash

function installchaincode(){
  echo "install ${CC_NAME} on ${CORE_PEER_ADDRESS}"
  CORE_PEER_ADDRESS=${peerName}
  peer chaincode install -n ${CC_NAME} -v ${upgradeVersion} -l ${LANGUAGE} -p ${CC_SRC_PATH} >&log.txt
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== ${CORE_PEER_ADDRESS} has failed to install chaincode '$CHANNEL_NAME' ===================== "
    exit 1
  fi
}

function upgradeChaincode(){
  echo "upgrade ${CC_NAME} on $CHANNEL_NAME"
  CORE_PEER_ADDRESS=${peerName}
  CMD='{"Args":["init","'${TZ}'"]}'
  peer chaincode upgrade -o ${CONNECT_ORDERER} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} -l ${LANGUAGE} -v ${upgradeVersion} -c ${CMD} -P "AND ('Org1MSP.peer')" >&log.txt
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== Chaincode is upgraded on ${CORE_PEER_ADDRESS} on channel '$CHANNEL_NAME' ===================== "
    exit 1
  fi
}

MODE=$1
peerName=$2
ccName=$3
upgradeVersion=$4

. scripts/comparms.sh
. scripts/env.sh

if [ "${MODE}" == "install" ]; then
  installchaincode
elif [ "${MODE}" == "upgrade" ]; then
  upgradeChaincode
else
  echo "wrong mode to operate BC"
  exit 1
fi