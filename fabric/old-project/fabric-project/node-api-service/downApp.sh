#!/bin/bash
#

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要刪除api服務? [Y/n] " ans
  case "$ans" in
  y | Y)
    echo "proceeding ..."
    ;;
  n | N)
    echo "exiting..."
    exit 1
    ;;
  *)
    echo "invalid response"
    askProceed
    ;;
  esac
}

# # Stop services only
# docker-compose stop
# # Stop and remove containers, networks..
# docker-compose down 
# # Down and remove volumes
# docker-compose down --volumes 

# ask for confirmation to proceed
askProceed

rm ./gateway/networkConnection.yaml
rm -rf ./gateway/crypto-config

docker-compose -f docker-compose.yaml down
