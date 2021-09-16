#!/bin/bash

# ====== 合約所需之參數 ======
# 合約使用的語言
LANGUAGE="golang"
# 透過cli要連線到的peer
CORE_PEER_ADDRESS=${peerName}:7051
# 與docker-compose-cli.yaml中的路徑相關
# 指令執行完後，合約安裝在peer容器中的/var/hyperledger/production/chaincodes
CC_SRC_PATH='github.com/chaincode/'${ccName}'/'
# 合約名稱
CC_NAME=${ccName}'cc'


# ====== 區塊鏈操作所需之參數 ======
# 指定要連線的orderer
CONNECT_ORDERER="orderer.example.com:7050"
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
# docker-compose-cli.yaml中也有此參數
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

