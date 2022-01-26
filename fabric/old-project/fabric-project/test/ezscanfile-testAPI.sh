#!/bin/bash

export $(cat .env)

CHANNEL_NAME=$(tail -n 1 ./genlist)

starttime=$(date +%s)

# echo "==================setImageHash=================="
# echo
# curl -s -X POST \
#   http://${EZSCANFILE_SERVICE}/ezscanfile/${CHANNEL_NAME}/ezscanfilecc/invoke/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
# 	\"chaincodeFunction\":\"set\",
# 	\"values\": {\"hash\" : \"d8a8a9a28e36b42f1f7b25d22e6339174759ec4178d38fcd217ac0a90eb1bf9c\", \"filename\" : \"abc.jpg\", \"time\" : \"20190826\", \"username\" : \"admin\", \"owner\" : \"一二三\", \"doctype\" : \"R&D Research\"}
# }"
# echo
# echo

# echo "==================checkByTxid=================="
# echo
# curl -s -X POST \
#   http://${EZSCANFILE_SERVICE}/ezscanfile/${CHANNEL_NAME}/ezscanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
# 	\"chaincodeFunction\":\"vtxid\",
# 	\"values\": {\"txid\" : \"5e1614ca889db38307b7f85165bf51c5704a7b5fd51dff022987f436a5fca576\"}
# }"
# echo
# echo

# echo "==================checkByHash=================="
# echo
# curl -s -X POST \
#   http://${EZSCANFILE_SERVICE}/ezscanfile/${CHANNEL_NAME}/ezscanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
#   \"chaincodeFunction\":\"vhash\",
#   \"values\": {\"hash\" : \"d8a8a9a28e36b42f1f7b25d22e6339174759ec4178d38fcd217ac0a90eb1bf9c\"}
# }"
# echo
# echo

# echo "==================checkBySerialNum=================="
# echo
# curl -s -X POST \
#   http://${EZSCANFILE_SERVICE}/ezscanfile/${CHANNEL_NAME}/ezscanfilecc/query/v1 \
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
#   http://${EZSCANFILE_SERVICE}/ezscanfile/${CHANNEL_NAME}/ezscanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
#   \"chaincodeFunction\":\"vserialnoblockid\",
#   \"values\": {\"serialnumber\" : \"1\", \"blockid\" : \"5fca576\"}
# }"
# echo
# echo

# echo "==================getHistoryByHash=================="
# echo
# curl -s -X POST \
#   http://${EZSCANFILE_SERVICE}/ezscanfile/${CHANNEL_NAME}/ezscanfilecc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
#   \"chaincodeFunction\":\"gethistory\",
#   \"values\": {\"hash\" : \"d8a8a9a28e36b42f1f7b25d22e6339174759ec4178d38fcd217ac0a90eb1bf9c\"}
# }"
# echo
# echo

echo "Total execution time : $(($(date +%s)-starttime)) secs ..."