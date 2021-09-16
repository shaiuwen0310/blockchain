#!/bin/bash

export $(cat .env)

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要刪除區塊鏈服務? [Y/n] " ans
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
    echo
    askProceed
    ;;
  esac
}

function downNode() {
  echo "====== 開始關閉fabric:${IMAGE_TAG} 網路 ======"
  echo

  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_ORDERER -f $COMPOSE_FILE_CA -f $COMPOSE_FILE_CLI down --volumes --remove-orphans

  # 所有暫存檔案，都在關閉fabric網路時，才全數刪除
  # 也就是api服務可以關閉後再啟動
  rm -rf ./../chaincode/rcc
  rm -rf genlist
  rm -rf peerlist
  rm -rf ./../../node-api-service/genlist
  rm -rf ./../../node-api-service/test1

  clearContainers
  removeUnwantedImages
  
  rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config

  echo "====== 完成關閉fabric:${IMAGE_TAG} 網路 ======"
  echo
}

function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer.*.*.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    # docker rm -f $CONTAINER_IDS
    docker rm $(docker ps -a --format {{.Names}} | grep dev-*)
  fi

}

function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*.*.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    # docker rmi -f $DOCKER_IMAGE_IDS
    docker rmi $(docker images dev-* -q)
  fi
}


# ask for confirmation to proceed
askProceed

# 設定檔
COMPOSE_FILE=docker-compose-peer.yaml
COMPOSE_FILE_ORDERER=docker-compose-orderer.yaml
COMPOSE_FILE_CA=docker-compose-ca.yaml
COMPOSE_FILE_CLI=docker-compose-cli.yaml

downNode


