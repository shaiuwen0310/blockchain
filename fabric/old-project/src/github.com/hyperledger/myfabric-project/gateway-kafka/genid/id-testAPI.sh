#!/bin/bash

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

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

# echo "==================enrollAdmin=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4001/id/asdce/a/v1 \
#   -H "content-type: application/json" \
#   -d "{
# 	\"values\" : {\"ca\" : \"ca-org1\",\"enrolled\" : \"admin\",\"pwd\" : \"adminpw\",\"mspid\" : \"Org1MSP\"} 
#   }"
# echo
# echo

# echo "==================registerUser=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4001/id/asdce/u/v1 \
#   -H "content-type: application/json" \
#   -d "{
# 	\"values\" : {\"newuser\" : \"user1\",\"enrolled\" : \"admin\",\"affiliation\" : \"org1.department1\",\"role\" : \"client\",\"mspid\" : \"Org1MSP\"} 
#   }"
# echo
# echo