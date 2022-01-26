#!/bin/bash

#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# ./generate.sh 預設值
# ./generate.sh -c mychannel 第一次增加檔案
# ./generate.sh -c yourchannel -g 多增加一個channel檔案

# default
CHANNEL_NAME=mychannel

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要清除並重建憑證、設定檔嗎? [Y/n] " ans
  case "$ans" in
  y | Y)
    echo "proceeding ..."
    ;;
  n | N)
    echo "exiting..."
    exit 1
    ;;
  *)
    echo "invalid response"
    askProceed
    ;;
  esac
}

function generateCerts() {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  if [ -d "crypto-config" ]; then
    rm -Rf crypto-config
  fi
  set -x
  cryptogen generate --config=./crypto-config.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
}

function replacePrivateKey() {

  if [ -f "docker-ca.yaml" ]; then
    rm -f docker-ca.yaml
  fi

  echo
  echo "##########################################################"
  echo "##### Copy docker-ca.yaml and replace CA1_PRIVATE_KEY ####"
  echo "##########################################################"
  
  # Copy the template to the file that will be modified to add the private key
  cp docker-ca-template.yaml docker-ca.yaml

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  CURRENT_DIR=$PWD
  cd crypto-config/peerOrganizations/org1.example.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed -i "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" docker-ca.yaml
  set -x
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to replace private Key..."
    exit 1
  fi
  echo
}

function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  # generate genesis block for orderer
  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  set -x
  configtxgen -profile SampleDevModeKafka -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo

  # generate channel configuration transaction
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"
  set -x
  configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  else
    # 已建立channel file 未create channel
    echo "${CHANNEL_NAME}" > genlist
  fi

#   # generate anchor peer transaction
#   echo
#   echo "#################################################################"
#   echo "#######    Generating anchor peer update for Org1MSP   ##########"
#   echo "#################################################################"
#   set -x
#   configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
#   res=$?
#   set +x
#   if [ $res -ne 0 ]; then
#     echo "Failed to generate anchor peer update for Org1MSP..."
#     exit 1
#   fi
}

function generateAnotherChannel(){
  # generate channel configuration transaction
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction ${CHANNEL_NAME} ###"
  echo "#################################################################"
  set -x
  if [ -f "./channel-artifacts/$CHANNEL_NAME.tx" ]; then
    echo "${CHANNEL_NAME} is exist..."
    exit 1
  fi
  configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  else
    # 已建立channel file 未create channel
    echo "${CHANNEL_NAME}" >> genlist
  fi
}

while getopts "c:g" opt; do
  case "$opt" in
   c)
    CHANNEL_NAME=$OPTARG
    ;;
   g)
    generateAnotherChannel
    exit 0
    ;;
  esac
done


# ask for confirmation to proceed
askProceed
# remove previous crypto material and config transactions
rm -fr channel-artifacts/*
rm -fr crypto-config/*

generateCerts
replacePrivateKey
generateChannelArtifacts