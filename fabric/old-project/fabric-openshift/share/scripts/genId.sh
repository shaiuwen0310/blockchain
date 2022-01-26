#!/bin/bash


NODE_SERVICE_SVC="${SERVICES_IP}:${SERVICES_PORT}"

starttime=$(date +%s)

# CA_ACCOUNT=admin
# CA_PWD=adminpw
# WALLET_USER=user1
# CHAINCODE=scanfile

if [ -d "${NFS_WALLET_PATH}/wallet/${CA_ACCOUNT}" ]; then
  echo "Admin ID has already been generated..."
  exit 1
fi

echo "Enroll admin user now..."
echo
curl -s -X POST \
  http://${NODE_SERVICE_SVC}/${CHAINCODE}/asdce/a/v1 \
  -H "content-type: application/json" \
  -d "{
	\"values\" : {\"ca\" : \"ca-org1\",\"enrolled\" : \"${CA_ACCOUNT}\",\"pwd\" : \"${CA_PWD}\",\"mspid\" : \"Org1MSP\"} 
  }"
echo
echo

sleep 10

if [ -d "${NFS_WALLET_PATH}/wallet/${WALLET_USER}" ]; then
  echo "User ID has already been generated..."
  exit 1
fi

echo "Register user now..."
echo
curl -s -X POST \
  http://${NODE_SERVICE_SVC}/${CHAINCODE}/asdce/u/v1 \
  -H "content-type: application/json" \
  -d "{
	\"values\" : {\"newuser\" : \"${WALLET_USER}\",\"enrolled\" : \"${CA_ACCOUNT}\",\"affiliation\" : \"org1.department1\",\"role\" : \"client\",\"mspid\" : \"Org1MSP\"} 
  }"
echo
echo "Generated walletID done, please check the file in wallet folder..."

echo
echo "Total execution time : $(($(date +%s)-starttime)) secs ..."