#!/bin/bash

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# echo "==================setImageHash=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/scanfile/mychannel/scanfilecc/invoke/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"set\",
# 	\"values\": {\"hash\" : \"hash1\", \"filename\" : \"filename1\"}
# }"
# echo
# echo

# echo "==================checkByTxid=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/scanfile/mychannel/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"chaincodeFunction\":\"vtxid\",
# 	\"values\": {\"txid\" : \"00c924f519361182f95c08ccef865acc4f79c8668aa428538740e8e1e5bbeb41\"}
# }"
# echo
# echo

# echo "==================checkByHash=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/scanfile/mychannel/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
#   \"chaincodeFunction\":\"vhash\",
#   \"values\": {\"hash\" : \"d8a8a9a28e36b42f1f7b25d22e6339174759ec4178d38fcd217ac0a90eb1bf9c\"}
# }"
# echo
# echo

# echo "==================checkBySerialNum=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/scanfile/mychannel/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
#   \"chaincodeFunction\":\"vserialno\",
#   \"values\": {\"serialnumber\" : \"1\"}
# }"
# echo
# echo

# echo "==================checkBySerialNumBlockId=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/scanfile/mychannel/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
#   \"chaincodeFunction\":\"vserialnoblockid\",
#   \"values\": {\"serialnumber\" : \"1\", \"blockid\" : \"5bbeb41\"}
# }"
# echo
# echo

# echo "==================getHistoryByHash=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/scanfile/mychannel/scanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
#   \"chaincodeFunction\":\"gethistory\",
#   \"values\": {\"hash\" : \"d8a8a9a28e36b42f1f7b25d22e6339174759ec4178d38fcd217ac0a90eb1bf9c\"}
# }"
# echo
# echo

echo "Total execution time : $(($(date +%s)-starttime)) secs ..."