#!/bin/bash

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

export $(cat .env)

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

if [ -d "./wallet/${CA_ACCOUNT}" ]; then
  echo "Admin ID has already been generated..."
  exit 1
fi

echo "Enroll admin user now..."
echo
curl -s -X POST \
  http://${TRACEABILITY_SERVICE}/traceability/asdce/a/v1 \
  -H "content-type: application/json" \
  -d "{
	\"values\" : {\"ca\" : \"ca-org1\",\"enrolled\" : \"${CA_ACCOUNT}\",\"pwd\" : \"${CA_PWD}\",\"mspid\" : \"Org1MSP\"} 
  }"
echo
echo

sleep 6

if [ -d "./wallet/${WALLET_USER}" ]; then
  echo "User ID has already been generated..."
  exit 1
fi

echo "Register user now..."
echo
curl -s -X POST \
  http://${TRACEABILITY_SERVICE}/traceability/asdce/u/v1 \
  -H "content-type: application/json" \
  -d "{
	\"values\" : {\"newuser\" : \"${WALLET_USER}\",\"enrolled\" : \"${CA_ACCOUNT}\",\"affiliation\" : \"org1.department1\",\"role\" : \"client\",\"mspid\" : \"Org1MSP\"} 
  }"
echo

echo "${WALLET_USER}" > ./../webui/wt

echo "Generated walletID done, plese check the file in wallet folder..."
