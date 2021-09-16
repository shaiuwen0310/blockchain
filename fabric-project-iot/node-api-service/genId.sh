#!/bin/bash

# 
# 固定使用iotdata0 建立userID
# 

export $(cat .env)

# 
CONTAINER_NAME=iotdata0
# fabric-network/ 的docker compose中 port:port設定一樣才可以下此指令; 要trim
p=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} {{end}}' ${CONTAINER_NAME} | cut -d"/" -f 1 | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//')
IOTDATA0_SERVICE=${SERVICE_IP}:${p}

# 
function EnrollAdmin(){
  echo
  echo "開始建立AdminID..."
  res=$(curl -s -X POST \
    http://${IOTDATA0_SERVICE}/iotdata/asdce/a/v1 \
    -H "content-type: application/json" \
    -d "{
    \"values\" : {\"ca\" : \"ca-org1\",\"enrolled\" : \"${CA_ACCOUNT}\",\"pwd\" : \"${CA_PWD}\",\"mspid\" : \"Org1MSP\"} 
    }")

  sleep 6

  if [ "${res}" = false ]; then
    echo "AdminID建立失敗..."
  else
    echo "AdminID建立完成..."
  fi
  echo
  echo
}

# usetID是唯一性的，即便刪掉資料夾，也還是存在CA中
function EnrollUser(){
  read -p "請輸入欲創建的USER ID: " WALLET_USER

  if [ -d "./wallet/${WALLET_USER}" ]; then
    echo
    echo "無法建立，此USER ID之資料夾已存在..."
    exit 1
  fi

  echo
  echo "開始建立userID..."
  res=$(curl -s -X POST \
    http://${IOTDATA0_SERVICE}/iotdata/asdce/u/v1 \
    -H "content-type: application/json" \
    -d "{
    \"values\" : {\"newuser\" : \"${WALLET_USER}\",\"enrolled\" : \"${CA_ACCOUNT}\",\"affiliation\" : \"org1.department1\",\"role\" : \"client\",\"mspid\" : \"Org1MSP\"} 
    }")

  if [ "${res}" = false ]; then
    echo "userID建立失敗..."
  else
    echo "userID建立完成..."
    echo
    echo "請確認路徑下確實有ID之資料夾..."
  fi

}



if [ ! -d "${WALLET_PATH}/${CA_ACCOUNT}" ]; then
  echo "尚未建立Admin ID..."
  EnrollAdmin
fi

EnrollUser
