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

# echo "==================createWine=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/wine/mychannel/winecc/invoke/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"fcn\":\"createWine\",
# 	\"args\": {\"name\" : \"name01\",\"place\" : \"place01\",\"year\" : \"year01\",\"winerymbr\" : \"winerymbr01\",\"taste\" : \"taste01\",\"color\" : \"color01\",\"yield\" : \"yield01\"}
# }"
# echo
# echo

# echo "==================insertJsonRecord=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/wine/mychannel/winecc/invoke/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"fcn\":\"createWinefromJsonFile\",
# 	\"args\": {\"name\" : \"name5\",\"place\" : \"place01\",\"year\" : \"year01\",\"winerymbr\" : \"winerymbr01\",\"taste\" : \"taste01\",\"color\" : \"color01\",\"yield\" : \"yield01\"}
# }"
# echo
# echo

# echo "==================insertHDFSRecord=================="
# echo
# curl -s -X POST \
#   http://127.0.0.1:4003/wine/mychannel/winecc/invoke/v1 \
#   -H "content-type: application/json" \
#   -d "{
#   \"userName\":\"user1\",
# 	\"fcn\":\"createWinefromJsonFile-hdfs\",
# 	\"args\":\"judy/wine1.json\"
# }"
# echo
# echo

# echo "==================queryWineBYkey=================="
# echo
# # args為key值
# res=$(curl -s -X GET \
#   "http://127.0.0.1:4003/wine/mychannel/winecc/query/v1?usr=user1&fcn=queryWine&values=judy-wine-name01" \
#   -H "content-type: application/json")
# echo
# echo "res: ${res}"
# echo
# echo

# echo "==================queryWineHistoryBYkey=================="
# echo
# # args為key值
# res=$(curl -s -X GET \
#   "http://127.0.0.1:4003/wine/mychannel/winecc/query/v1?usr=user1&fcn=getHistoryForWine&values=judy-wine-name01" \
#   -H "content-type: application/json")
# echo
# echo "res: ${res}"
# echo
# echo

# echo "==================queryWineByPlace=================="
# echo
# # args為key值
# res=$(curl -s -X GET \
#   "http://127.0.0.1:4003/wine/mychannel/winecc/query/v1?usr=user1&fcn=queryWineByPlace&values=place01" \
#   -H "content-type: application/json")
# echo
# echo "res: ${res}"
# echo
# echo

# echo "==================queryWinesWithPagination=================="
# echo
# # 分頁查詢
# res=$(curl -s -X GET \
#   "http://127.0.0.1:4003/wine/mychannel/winecc/pagination/v1?usr=user1&fcn=queryWinesWithPagination&fld=winerymbr&val=winerymbr01&page=3&tag=nil")
# echo
# echo "res: ${res}"
# echo
# echo

# echo "==================deleteWineBYkey=================="
# echo
# # args為key值
# res=$(curl -s -X GET \
#   "http://127.0.0.1:4003/wine/mychannel/winecc/delete/v1?usr=user1&fcn=deleteWineBYkey&values=judy-wine-NAME1" \
#   -H "content-type: application/json")
# echo
# echo "res: ${res}"
# echo
# echo

