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

# echo "==================newtoken=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/token/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"newtoken\",
# 	\"values\": {\"tokenname\" : \"a\",\"symbol\" : \"AAA\",\"value\" : \"180\",\"total\" : \"10000000\",\"tokenaccount\" : \"coinbase\",\"corporation\" : \"a corp\",\"walletid\" : \"user1\"}
# }"
# echo
# echo

# echo "==================activateToken=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/token/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"activatetoken\",
# 	\"values\": {\"tokenname\" : \"a\",\"tokenaccount\" : \"coinbase\",\"walletid\" : \"user1\"}
# }"
# echo
# echo

# echo "==================freezenatoken=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/token/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"freezenatoken\",
# 	\"values\": {\"tokenname\" : \"c\",\"tokenaccount\" : \"coinbase\",\"walletid\" : \"user1\"}
# }"
# echo
# echo

# echo "==================deleteatoken=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/token/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"deleteatoken\",
# 	\"values\": {\"tokenname\" : \"c\",\"tokenaccount\" : \"coinbase\",\"walletid\" : \"user1\"}
# }"
# echo
# echo

# echo "==================informationoftoken=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/token/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"informationoftoken\",
# 	\"values\": {\"tokenname\" : \"a\"}
# }"
# echo
# echo

# echo "==================supplytotaloftoken=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/token/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"supplytotaloftoken\",
# 	\"values\": {\"tokenname\" : \"a\"}
# }"
# echo
# echo

# echo "==================historyoftokenaccount=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/token/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"historyoftokenaccount\",
# 	\"values\": {\"tokenname\" : \"a\",\"tokenaccount\" : \"coinbase\"}
# }"
# echo
# echo

# echo "==================newamemberaccount=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/member/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"newamemberaccount\",
# 	\"values\": {\"membername\" : \"member1\",\"account\" : \"acc1\",\"walletid\" : \"user1\"}
# }"
# echo
# echo

# echo "==================activatememberaccount=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/member/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"activatememberaccount\",
# 	\"values\": {\"account\" : \"acc1\",\"walletid\" : \"user1\"}
# }"
# echo
# echo

# echo "==================freezenmember=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/member/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"freezenmember\",
# 	\"values\": {\"account\" : \"acc1\",\"walletid\" : \"user1\"}
# }"
# echo
# echo

# echo "==================memberapprove=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/member/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"memberapprove\",
# 	\"values\": {\"myaccount\" : \"acc1\",\"hisaccount\" : \"acc2\",\"value\" : \"1000\",\"walletid\" : \"user1\"}
# }"
# echo
# echo

# echo "==================memberallowance=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/member/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"memberallowance\",
# 	\"values\": {\"myaccount\" : \"acc1\", \"hisaccount\" : \"acc2\"}
# }"
# echo
# echo

# echo "==================memberbalanceof=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/member/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"memberbalanceof\",
# 	\"values\": {\"memberaccount\" : \"acc1\"}
# }"
# echo
# echo

# echo "==================getmemberallowance=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/member/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"getmemberallowance\",
# 	\"values\": {\"myaccount\" : \"acc1\", \"hisaccount\" : \"acc2\"}
# }"
# echo
# echo

# echo "==================gethistoryofaccount=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/member/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"gethistoryofaccount\",
# 	\"values\": {\"memberaccount\" : \"acc1\"}
# }"
# echo
# echo

# echo "==================transfers=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/txn/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"transfers\",
# 	\"values\": {\"tokenname\" : \"a\", \"tokenaccount\" : \"coinbase\", \"memberaccount\" : \"acc1\", \"counts\" : \"6700000\", \"walletid\" : \"user1\", \"choose\" : \"coinbase\"}
# }"
# echo
# echo

# echo "==================transferfroms=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/txn/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"transferfroms\",
# 	\"values\": {\"tokenname\" : \"a\", \"memberfromaccount\" : \"acc1\", \"membertoaccount\" : \"acc2\", \"counts\" : \"1\", \"walletid\" : \"user1\"}
# }"
# echo
# echo

# echo "==================exchangetoken=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/mytokens/mychannel/mytokenscc/txn/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"exchangetoken\",
# 	\"values\": {\"memberacc\" : \"acc1\",\"holdingtoken\" : \"a\",\"holdingtokenacc\" : \"coinbase\",\"holdingtokennumber\" : \"2\",\"exchangetoken\" : \"b\",\"exchangetokenacc\" : \"coinbase\",\"walletid\" : \"user1\"}
# }"
# echo
# echo