#!/bin/bash

# 匯出fabric docker images
# 根據不同系統，資料夾名稱也不同

FABRIC_TAG=2.2
FABRIC_CA_TAG=1.5

OS_ARCH=$(echo "$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
EXPORT_FOLDER=images-${OS_ARCH}

# Ask user for confirmation to proceed
function askProceed() {
  echo "匯出tag版本: fabric:${FABRIC_TAG}，fabric_ca:${FABRIC_CA_TAG}"
  echo ""
  read -p "確定要匯出docker images嗎？[y/n]" ans
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

function createFolder() {
  if [ ! -d ${EXPORT_FOLDER} ]; then
    mkdir ${EXPORT_FOLDER}
  fi
}

function exportImages() {

  echo "====== 開始匯出docker images ======"
  echo "須花費一段時間..."
  echo
  starttime=$(date +%s)

  echo "下載hyperledger/fabric-ca:${FABRIC_CA_TAG}..."
  docker save hyperledger/fabric-ca:${FABRIC_CA_TAG} > ${EXPORT_FOLDER}/fabric-ca-${FABRIC_CA_TAG}.tar
  echo "rtnc: ${?}"
  echo ""

  echo "下載hyperledger/fabric-tools:${FABRIC_TAG}..."
  docker save hyperledger/fabric-tools:${FABRIC_TAG} > ./${EXPORT_FOLDER}/fabric-tools-${FABRIC_TAG}.tar
  echo "rtnc: ${?}"
  echo ""

  echo "下載hyperledger/fabric-ccenv:${FABRIC_TAG}..."
  docker save hyperledger/fabric-ccenv:${FABRIC_TAG} > ./${EXPORT_FOLDER}/fabric-ccenv-${FABRIC_TAG}.tar
  echo "rtnc: ${?}"
  echo ""

  echo "下載hyperledger/fabric-orderer:${FABRIC_TAG}..."
  docker save hyperledger/fabric-orderer:${FABRIC_TAG} > ./${EXPORT_FOLDER}/fabric-orderer-${FABRIC_TAG}.tar
  echo "rtnc: ${?}"
  echo ""

  echo "下載hyperledger/fabric-peer:${FABRIC_TAG}..."
  docker save hyperledger/fabric-peer:${FABRIC_TAG} > ./${EXPORT_FOLDER}/fabric-peer-${FABRIC_TAG}.tar
  echo "rtnc: ${?}"
  echo ""

  echo "下載hyperledger/fabric-baseos:${FABRIC_TAG}..."
  docker save hyperledger/fabric-baseos:${FABRIC_TAG} > ./${EXPORT_FOLDER}/fabric-baseos-${FABRIC_TAG}.tar
  echo "rtnc: ${?}"
  echo ""

  echo "下載node:8.16.0..."
  docker save node:8.16.0 > ./${EXPORT_FOLDER}/node-8.16.tar
  echo "rtnc: ${?}"
  echo ""

  echo "下載node:16.13.0..."
  docker save node:16.13.0 > ./${EXPORT_FOLDER}/node-16.13.tar
  echo "rtnc: ${?}"
  echo ""

  echo "下載nginx:latest..."
  docker save nginx:latest > ./${EXPORT_FOLDER}/nginx-latest.tar
  echo "rtnc: ${?}"
  echo ""

  echo "Total execution time: $(($(date +%s)-starttime)) secs"
  echo "====== 結束匯出docker images ======"
}


askProceed
if [ ! -d ${EXPORT_FOLDER} ]; then
  mkdir ${EXPORT_FOLDER}
  echo ""
  echo "建立${EXPORT_FOLDER}資料夾，用於存放images"
  echo ""
else
  echo "${EXPORT_FOLDER}資料夾已存在..."
  exit 0
fi

exportImages
