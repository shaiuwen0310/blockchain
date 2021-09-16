#!/bin/bash
#

# 
# 刪除後，若沒有再去關閉fabric網路，可重新執行runApp.sh並重新產生
# 刪除後，log也會被刪除
# 

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要刪除api服務? [Y/n] " ans
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

# Stop services only
# docker-compose stop

# Stop and remove containers, networks..
# docker-compose down 

# Down and remove volumes
# docker-compose down --volumes 


# ask for confirmation to proceed
askProceed

rm -rf ./gateway/crypto-config
rm -rf ./gateway/iotNet.yaml

docker-compose -f docker-compose.yaml down
