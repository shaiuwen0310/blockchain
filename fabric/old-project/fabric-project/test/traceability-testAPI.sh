#!/bin/bash

export $(cat .env)

CHANNEL_NAME=$(tail -n 1 ./genlist)

starttime=$(date +%s)

# echo "==================setInfo=================="
# echo
# curl -s -X POST \
#   http://${TRACEABILITY_SERVICE}/traceability/${CHANNEL_NAME}/traceabilitycc/invoke/v1 \
#   -H "content-type: application/json" \
#   -d @data_noBase64.json
# echo
# echo

# echo "==================verifyInfo=================="
# echo
# curl -s -X POST \
#   http://${TRACEABILITY_SERVICE}/traceability/${CHANNEL_NAME}/traceabilitycc/invoke/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
# 	\"chaincodeFunction\":\"verify\",
# 	\"values\": {\"txid\" : \"75b9abd9261490a0dc897fdb0484ce544683119c8e2349a65f955cd82d0007e8\", \"trackingNumber\" : \"20180101d0007e8199998\", \"productToken\" : \"1261721\"}
# }"
# echo
# echo

# echo "==================quantityInfo=================="
# echo
# curl -s -X POST \
#   http://${TRACEABILITY_SERVICE}/traceability/${CHANNEL_NAME}/traceabilitycc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
# 	\"chaincodeFunction\":\"quantity\",
# 	\"values\": {\"productName\" : \"Aegis combat system\"}
# }"
# echo
# echo

# echo "==================checkByHash=================="
# echo
# curl -s -X POST \
#   http://${TRACEABILITY_SERVICE}/traceability/${CHANNEL_NAME}/traceabilitycc/query/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
# 	\"chaincodeFunction\":\"checkbyhash\",
# 	\"values\": {\"picHash\" : \"736df107b4d99cd5aa400eba7bd043755001ca8d5d47e408d33ac618765ebe1d\"}
# }"
# echo
# echo

# echo "==================delInfo=================="
# echo
# curl -s -X POST \
#   http://${TRACEABILITY_SERVICE}/traceability/${CHANNEL_NAME}/traceabilitycc/invoke/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"${USER_NAME}\",
# 	\"chaincodeFunction\":\"del\",
# 	\"values\": {\"productName\" : \"Aegis combat system\", \"produceDate\" : \"20180101\", \"operateDate\" : \"20190101\"}
# }"
# echo
# echo

echo "Total execution time : $(($(date +%s)-starttime)) secs ..."

