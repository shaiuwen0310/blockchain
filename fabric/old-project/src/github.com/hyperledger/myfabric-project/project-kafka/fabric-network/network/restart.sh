#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.

# ./start.sh 第一次執行
# ./start.sh -a yourchannel 增加一個合約

# 啟動節點
function startNode() {
  echo "====== restart the fabric network ======"
  echo
  docker-compose -f docker-zookeeper.yaml up -d
  sleep 6
  docker-compose -f docker-kafka.yaml up -d
  sleep 6
  docker-compose -f docker-orderer.yaml up -d
  sleep 3
  docker-compose -f docker-couchdb.yaml up -d
  sleep 3
  docker-compose -f docker-peer.yaml up -d
  sleep 3
  docker-compose -f docker-ca.yaml up -d
  sleep 3
  docker-compose -f docker-cli.yaml up -d
  echo "====== end the fabric network ======"
  echo
}

startNode
