#!/bin/bash

# 
# 功能：
#    建立憑證(資料夾)，建立一個orderer系統設定檔案，一個帳本
# 

export $(cat .env)

# default
CHANNEL_NAME=mychannel

# Ask user for confirmation to proceed
function askProceed() {
  echo 
  echo "帳本名稱：${CHANNEL_NAME}，若要'更改'請按N"
  if [ -d "crypto-config" ]; then echo "已經建立過憑證、設定檔，若'不刪除'請按N"; fi
  read -p "確定要建立(或重建)所有憑證、設定檔嗎？ [Y/N] " ans
  case "$ans" in
  y | Y)
    echo "繼續往下執行..."
    ;;
  n | N)
    echo "離開..."
    echo
    echo "設定 帳本名稱(預設mychannel): ./generate.sh -c <channel name>"
    exit 1
    ;;
  *)
    echo "不合法回覆..."
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
  # orderer的系統設定檔案
  CHANNEL_ID=${NETWORK_NAME}-sys-${CHANNEL_NAME}
  configtxgen -profile SampleMultiNodeEtcdRaft -channelID ${CHANNEL_ID} -outputBlock ./channel-artifacts/genesis.block
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo

  # generate channel configuration transaction
  echo "#################################################################"
  echo "### Generating channel configuration transaction '${CHANNEL_NAME}' ###"
  echo "#################################################################"
  set -x
  configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME}
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  else
    echo "${CHANNEL_NAME}" | tee -a genlist ../../node-api-service/genlist
  fi

}


while getopts "c:" opt
do
  case "$opt" in
   c)
    # 更改帳本名稱
    CHANNEL_NAME=$OPTARG
    ;;
  esac
done

# ask for confirmation to proceed
askProceed
# remove previous crypto material and config transactions
rm -fr channel-artifacts/*
rm -fr crypto-config/*
rm -rf genlist
rm -rf ../../node-api-service/genlist

generateCerts
generateChannelArtifacts
