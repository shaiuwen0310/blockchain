#!/bin/bash
#

cd /home/judy/go/src/github.com/hyperledger/myfabric-project/gateway-raft/fabric-network/network

export BYFN_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/ca && ls *_sk)

docker-compose -f docker-compose-cli.yaml -f docker-compose-ca.yaml -f docker-compose-etcdraft2.yaml up -d
