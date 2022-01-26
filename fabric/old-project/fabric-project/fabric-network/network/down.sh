#!/bin/bash

export $(cat .env)

# Ask user for confirmation to proceed
function askProceed() {
  read -p "確定要刪除區塊鏈服務? [Y/n] " ans
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

function downNode() {
  echo "====== down the fabric network ======"
  echo

  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_RAFT2 -f $COMPOSE_FILE_CA down --volumes --remove-orphans

  # config by myself
  rm -rf ./../chaincode/rcc
  rm -rf genlist
  rm -rf peerlist
  rm -rf ./../../node-api-service/genlist
  rm -rf ./../../webui/genlist
  rm -rf ./../../webui/wt
  rm -rf ./../../test/genlist
  rm -rf ./../../webui/docker-compose.yaml

  clearContainers
  removeUnwantedImages
  
  rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config

  echo "====== down the fabric network ======"
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

COMPOSE_FILE=docker-compose-cli.yaml
#
COMPOSE_FILE_COUCH=docker-compose-couch.yaml
# two additional etcd/raft orderers
COMPOSE_FILE_RAFT2=docker-compose-etcdraft2.yaml
# certificate authorities compose file
COMPOSE_FILE_CA=docker-compose-ca.yaml

downNode


