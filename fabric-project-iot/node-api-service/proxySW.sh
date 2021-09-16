#!/bin/bash
#

# 
# proxy switch: 開關reverse proxy
# 用途：使外部 可以/無法 使用api-service，單獨啟動reverse proxy的前提，api服務都要起來
# 

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要「啟動」或「暫停」reverse proxy嗎? [Y/n] " ans
  case "$ans" in
  y | Y)
    echo "繼續往下執行..."
    ;;
  n | N)
    echo "離開..."
    exit 1
    ;;
  *)
    echo "不合法回覆..."
    askProceed
    ;;
  esac
}

function SW(){
  echo
  echo "1 啟動"
  echo "2 暫停"
  read -p "請輸入1或2: " n
  case "${n}" in
  1)
    echo "啟動reverse proxy..."
    # 先確認api服務都存在，才可啟動reverseproxy
    checkHost;
    if [ "$?" = "0" ]; then docker-compose -f docker-compose.yaml up -d reverseproxy; fi;
    ;;
  2)
    echo "暫停reverse proxy..."
    docker stop reverseproxy
    ;;
  3)
    echo "離開..."
    exit 0
    ;;
  *)
    echo "不合法回覆...可輸入3 離開..."
    SW
    ;;
  esac
}

# reverse proxy啟動前，api服務要先存在才可以
function checkHost(){
  apiName="iotdata"

  # 幾個帳本就有幾個api服務
  END=$(wc -l genlist | cut -d" " -f 1)
  # 查看每個api服務是否啟動
  for i in $(seq 1 $END);
  do
    name=$(docker ps --format "{{.Names}}" | grep "${apiName}$(($i-1))$")
    res=$?
    if [ "${res}" = "1" ]; then
      echo
      echo "檢核${apiName}$(($i-1)) 未啟動...請先確認api服務皆啟動..."
      return 1
    fi
  done

  return 0
}

# ask for confirmation to proceed
askProceed

SW

