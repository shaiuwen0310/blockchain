#!/bin/bash

# ====== fabric env parm ======
VERSION="1.0"
LANGUAGE="golang"

CORE_PEER_ADDRESS=${peerName}:7051
CC_SRC_PATH='github.com/chaincode/'${ccName}'/'
CC_NAME=${ccName}'cc'

# basepath=$(cd `dirname $0`; pwd)
# echo "${basepath}"

# ====== custom parm ======
CONNECT_ORDERER="orderer.example.com:7050"
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
