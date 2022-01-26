#!/bin/bash

#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要刪除區塊鏈網路? [Y/n] " ans
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

docker-compose -f docker-zookeeper.yaml down
docker-compose -f docker-kafka.yaml down
docker-compose -f docker-orderer.yaml down
docker-compose -f docker-couchdb.yaml down
docker-compose -f docker-peer.yaml down
docker-compose -f docker-ca.yaml down
docker-compose -f docker-cli.yaml down

echo
echo "you need to run clearup.sh!!!"
echo