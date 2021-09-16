#!/bin/bash
#

# 
# 功能
#   用於開機自動重起，須另外做設定
# 

cd ${app_root_path}/fabric-network/network

# 設定檔
COMPOSE_FILE=docker-compose-peer.yaml
COMPOSE_FILE_ORDERER=docker-compose-orderer.yaml
COMPOSE_FILE_CA=docker-compose-ca.yaml
COMPOSE_FILE_CLI=docker-compose-cli.yaml

COMPOSE_FILES="-f ${COMPOSE_FILE} -f ${COMPOSE_FILE_CA} -f ${COMPOSE_FILE_ORDERER}"
export BYFN_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/ca && ls *_sk)

docker-compose ${COMPOSE_FILES} up -d 2>&1

sleep 1
echo "15秒鐘等待orderer啟動..."
sleep 14

docker-compose -f ${COMPOSE_FILE_CLI} up -d 2>&1
