#!/bin/bash

#預設CHANNEL_NAME:  ./generate.sh
#設定CHANNEL_NAME: ./generate.sh -c <channel name>

# default
CHANNEL_NAME=mychannel

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要清除並重建憑證、設定檔嗎? [Y/N] " ans
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
    echo
    echo "預設CHANNEL_NAME: ./generate.sh"
    echo "設定CHANNEL_NAME: ./generate.sh -c <channel name>"
    echo
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
  configtxgen -profile SampleMultiNodeEtcdRaft -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
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
  configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  else
    # 已建立channel file 未create channel
    echo "${CHANNEL_NAME}" > genlist
    echo "${CHANNEL_NAME}" > ../../node-api-service/genlist
    echo "${CHANNEL_NAME}" > ../../webui/genlist
    echo "${CHANNEL_NAME}" > ../../test/genlist
  fi

}

while getopts "c:" opt; do
  case "$opt" in
   c)
    CHANNEL_NAME=$OPTARG
    ;;
  esac
done

# ask for confirmation to proceed
askProceed
# remove previous crypto material and config transactions
rm -fr channel-artifacts/*
rm -fr crypto-config/*

generateCerts
generateChannelArtifacts