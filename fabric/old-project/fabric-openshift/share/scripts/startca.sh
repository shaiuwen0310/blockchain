#!/bin/bash


fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.org1.example.com-cert.pem --ca.keyfile ${FABRIC_CA_SERVER_TLS_KEYFILE} -b "${CA_ACCOUNT}:${CA_PWD}" -d
