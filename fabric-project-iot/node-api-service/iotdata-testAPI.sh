#!/bin/bash

# 
# 儲存的測試交易，透過這支帶起合約容器
# 

GET=$1

# 目前只用來抓SERVICE_IP
export $(cat .env)

CHANNEL_NAME=$(cat genlist | head -n 1)

# 不使用nginx，fabric-network/ 的docker compose中 port:port設定一樣才可以下此指令; 要trim
# CONTAINER_NAME=iotdata0
# p=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} {{end}}' ${CONTAINER_NAME} | cut -d"/" -f 1 | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//')

# nginx中設定5000
p=5000

# 取得毫秒
function getTiming(){ 
    start=$1
    end=$2
  
    start_s=$(echo $start | cut -d '.' -f 1)
    start_ns=$(echo $start | cut -d '.' -f 2)
    end_s=$(echo $end | cut -d '.' -f 1)
    end_ns=$(echo $end | cut -d '.' -f 2)

    time=$(( ( 10#$end_s - 10#$start_s ) * 1000 + ( 10#$end_ns / 1000000 - 10#$start_ns / 1000000 ) ))

    echo "$time ms"
}

function getHash(){
  read -p "請輸入要使用的userID(例如user1): " USER_NAME
  echo
  read -p "請輸入txid: " TXID_VALUE
  echo
  read -p "請輸入time: " TIME_VALUE

  echo "==================getHash=================="
  echo
  start2=$(date +%s.%N)
  start2_sec=$(date +%s)
  
  curl -s -X POST \
    http://${SERVICE_IP}:${p}/iotdata/iotdatacc/query/v1 \
    -H "content-type: application/json" \
    -d "{
    \"channelName\":\"${CHANNEL_NAME}\",
    \"userName\":\"${USER_NAME}\",
    \"chaincodeFunction\":\"get\",
    \"values\": {\"txid\" : \"${TXID_VALUE}\", \"time\" : \"${TIME_VALUE}\"}
  }"
  echo
  echo
  end2=$(date +%s.%N)
  echo "Total execution time: $(($(date +%s)-start2_sec)) secs ($(getTiming $start2 $end2))"
}


if [ "${GET}" == "get" ]; then
  getHash
  exit 0
fi

read -p "請輸入要使用的userID(例如user1): " USER_NAME
echo
read -p "請輸入hash值: " HASH_VALUE
echo
read -p "請輸入device編號: " DEVICE_VALUE
echo

start=$(date +%s.%N)
start_sec=$(date +%s)

echo "================== 儲存 hash 值 =================="
curl -s -X POST \
  http://${SERVICE_IP}:${p}/iotdata/iotdatacc/invoke/v1 \
  -H "content-type: application/json" \
  -d "{
  \"channelName\":\"${CHANNEL_NAME}\",
  \"userName\":\"${USER_NAME}\",
  \"chaincodeFunction\":\"set\",
  \"values\": {\"hash\" : \"${HASH_VALUE}\", \"device\" : \"${DEVICE_VALUE}\"}
}"
echo

end=$(date +%s.%N)
echo "Total execution time: $(($(date +%s)-start_sec)) secs ($(getTiming $start $end))"
echo
