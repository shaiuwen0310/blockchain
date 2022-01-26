#!/bin/bash

cd /home/judy/go/src/github.com/hyperledger/myfabric-project/iotGW/fabric-network/network

# 啟動節點
  echo "====== restart the fabric network ======"
  echo
  docker-compose -f docker-zookeeper.yaml up -d
  sleep 6
  docker-compose -f docker-kafka.yaml up -d
  sleep 6
  docker-compose -f docker-orderer.yaml up -d
  sleep 3
  docker-compose -f docker-peer.yaml up -d
  sleep 3
  docker-compose -f docker-ca.yaml up -d
  sleep 3
  docker-compose -f docker-cli.yaml up -d
  echo "====== end the fabric network ======"
  echo
