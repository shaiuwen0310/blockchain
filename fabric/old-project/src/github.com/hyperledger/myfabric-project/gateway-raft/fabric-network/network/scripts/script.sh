#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.

function createchannel() {
  echo "creat channel ${CHANNEL_NAME}"
  peer channel create -o ${CONNECT_ORDERER} -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== Channel '$CHANNEL_NAME' creation failed ===================== "
    exit 1
  fi
}

function joinchannel() {
  echo "${CORE_PEER_ADDRESS} join to ${CHANNEL_NAME}"
  peer channel join -b $CHANNEL_NAME.block >&log.txt
  sleep 3
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== ${CORE_PEER_ADDRESS} has failed to join channel '$CHANNEL_NAME' ===================== "
    exit 1
  fi
}

function installchaincode(){
  echo "install ${CC_NAME} on ${CORE_PEER_ADDRESS}"
  peer chaincode install -n ${CC_NAME} -v ${VERSION} -l ${LANGUAGE} -p ${CC_SRC_PATH} >&log.txt
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== ${CORE_PEER_ADDRESS} has failed to join channel '$CHANNEL_NAME' ===================== "
    exit 1
  fi
}

function instantiateChaincode(){
  echo "instantiate ${CC_NAME} on $CHANNEL_NAME"
  peer chaincode instantiate -o ${CONNECT_ORDERER} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} -l ${LANGUAGE} -v 1.0 -c '{"Args":["init",""]}' -P "AND ('Org1MSP.peer')" >&log.txt
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== Chaincode is instantiated on ${CORE_PEER_ADDRESS} on channel '$CHANNEL_NAME' ===================== "
    exit 1
  fi
}

MODE=$1
peerName=$2
ccName=$3

. scripts/params.sh
. scripts/channel.sh

if [ "${MODE}" == "createchannel" ]; then
  createchannel
elif [ "${MODE}" == "joinchannel" ]; then
  joinchannel
elif [ "${MODE}" == "install" ]; then
  installchaincode
elif [ "${MODE}" == "instantiate" ]; then
  instantiateChaincode
else
  echo "wrong mode to operate BC"
  exit 1
fi