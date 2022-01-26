#!/bin/bash

#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要清空所有設定、憑證嗎? [Y/n] " ans
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

# ask for confirmation to proceed
askProceed

# remove previous crypto material and config transactions
rm -fr channel-artifacts/*
rm -fr crypto-config
rm -rf docker-ca.yaml
rm -rf ~/.hfc-key-store/*

rm ./../chaincode/rcc
rm genlist
rm peerlist
rm ./../../node-api-service/gateway/networkConnection.yaml

# remove chaincode docker images
docker rm $(docker ps -a --format {{.Names}} | grep dev-*)
docker rmi $(docker images dev-* -q)

echo
echo
echo "################## 記得手動刪除walletID ##################"
echo
echo
echo