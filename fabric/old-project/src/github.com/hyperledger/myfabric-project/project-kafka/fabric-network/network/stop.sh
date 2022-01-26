#!/bin/bash

#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要停止區塊鏈網路? [Y/n] " ans
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

# # Stop services only
# docker-compose stop
# # Stop and remove containers, networks..
# docker-compose down 
# # Down and remove volumes
# docker-compose down --volumes 

# ask for confirmation to proceed
askProceed

docker-compose -f docker-zookeeper.yaml stop
docker-compose -f docker-kafka.yaml stop
docker-compose -f docker-orderer.yaml stop
docker-compose -f docker-couchdb.yaml stop
docker-compose -f docker-peer.yaml stop
docker-compose -f docker-ca.yaml stop
docker-compose -f docker-cli.yaml stop

echo
echo "you can restart again, if you don't delete any file!!!"
echo