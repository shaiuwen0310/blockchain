#!/bin/bash

export $(cat .env)

CHANNEL_NAME=$(tail -n 1 ./genlist)

starttime=$(date +%s)

# echo "==================setImageHash=================="
# echo
# curl -s -X POST \
#   http://${SCANFILE_SERVICE}/scanfile/${CHANNEL_NAME}/scanfilecc/invoke/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
# 	\"chaincodeFunction\":\"set\",
# 	\"values\": {\"hash\" : \"hash1\", \"filename\" : \"filename1\", \"time\" : \"20190826\", \"name\" : \"一二三\"}
# }"
# echo
# echo

# echo "==================checkByTxid=================="
# echo
# curl -s -X POST \
#   http://${SCANFILE_SERVICE}/scanfile/${CHANNEL_NAME}/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
# 	\"chaincodeFunction\":\"vtxid\",
# 	\"values\": {\"txid\" : \"f73d7464268d6ebb52df9c2e7f330ab6027f3b5bd4e007cc1fc3a981a9d11ec5\"}
# }"
# echo
# echo

# echo "==================checkByHash=================="
# echo
# curl -s -X POST \
#   http://${SCANFILE_SERVICE}/scanfile/${CHANNEL_NAME}/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
#   \"chaincodeFunction\":\"vhash\",
#   \"values\": {\"hash\" : \"hash1\"}
# }"
# echo
# echo

# echo "==================checkBySerialNum=================="
# echo
# curl -s -X POST \
#   http://${SCANFILE_SERVICE}/scanfile/${CHANNEL_NAME}/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
#   \"chaincodeFunction\":\"vserialno\",
#   \"values\": {\"serialnumber\" : \"1\"}
# }"
# echo
# echo

# echo "==================checkBySerialNumBlockId=================="
# echo
# curl -s -X POST \
#   http://${SCANFILE_SERVICE}/scanfile/${CHANNEL_NAME}/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
#   \"chaincodeFunction\":\"vserialnoblockid\",
#   \"values\": {\"serialnumber\" : \"1\", \"blockid\" : \"9d11ec5\"}
# }"
# echo
# echo

# echo "==================getHistoryByHash=================="
# echo
# curl -s -X POST \
#   http://${SCANFILE_SERVICE}/scanfile/${CHANNEL_NAME}/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
#   \"chaincodeFunction\":\"gethistory\",
#   \"values\": {\"hash\" : \"hash1\"}
# }"
# echo
# echo

echo "Total execution time : $(($(date +%s)-starttime)) secs ..."