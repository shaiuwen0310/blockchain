#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.

function createchannel() {
  echo "creat channel ${CHANNEL_NAME}"
  peer channel create -o ${CONNECT_ORDERER} -c $CHANNEL_NAME -f ./config/$CHANNEL_NAME.tx
}

function joinchannel() {
  echo "${CORE_PEER_ADDRESS} join to ${CHANNEL_NAME}"
  peer channel join -b $CHANNEL_NAME.block
  sleep 3
}

function installchaincode(){
  echo "install ${CC_NAME} on ${CORE_PEER_ADDRESS}"
  peer chaincode install -n ${CC_NAME} -v ${VERSION} -l ${LANGUAGE} -p ${CC_SRC_PATH}
}

function instantiateChaincode(){
  echo "instantiate ${CC_NAME} on $CHANNEL_NAME"
  peer chaincode instantiate -o ${CONNECT_ORDERER} -C $CHANNEL_NAME -n ${CC_NAME} -l ${LANGUAGE} -v ${VERSION} -c '{"Args":[""]}'
}

MODE=$1
peerName=$2
ccName=$3

. scripts/comparm.sh
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