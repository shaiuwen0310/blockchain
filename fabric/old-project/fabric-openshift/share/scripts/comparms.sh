#!/bin/bash

# ====== fabric env parm ======
VERSION="1.0"
LANGUAGE="golang"

CC_SRC_PATH='github.com/chaincode/'${ccName}'/'
CC_NAME=${ccName}'cc'

# ====== custom parm ======
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
