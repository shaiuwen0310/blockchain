#!/bin/bash

# 
# 功能：建立一個新帳本，並加入區塊鏈網路中
# 

export $(cat .env)

# 建立新帳本
function newChannel(){
  # 防止順序錯誤
  if [ ! -d "crypto-config" ]; then
    echo "尚未建立初始資料..."
    exit 1
  fi

  NEW_CHANNEL=$1
  # 防止帳本名稱重複
  if [ -f "./channel-artifacts/${NEW_CHANNEL}.tx" ]; then
    echo "'${NEW_CHANNEL}'帳本名稱重複..."
    exit 1
  fi

  # generate channel configuration transaction
  echo "#################################################################"
  echo "### Generating channel configuration transaction '${NEW_CHANNEL}' ###"
  echo "#################################################################"
  set -x
  configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${NEW_CHANNEL}.tx -channelID ${NEW_CHANNEL}
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  else
    echo "${NEW_CHANNEL}" | tee -a genlist ../../node-api-service/genlist
  fi
}

# 建立帳本(channel)至orderer中
function createLedger(){
    echo "建立${NEW_CHANNEL}帳本..."
    docker exec cli scripts/script.sh createchannel "" "" $NEW_CHANNEL
    sleep 3
}

# 將所有peer加入帳本(channel)中
function joinChannel(){
  channel_name=$1
  FILENAME=peerlist
  for peer_name in `cat $FILENAME`
  do
    docker exec cli scripts/script.sh joinchannel ${peer_name} "" ${channel_name} ""
    sleep 3
  done
}

# 實例化合約，也可以說是將合約加入channel
# 找這個peer對應的chaincode容器，抓取其chaincode版本號，並將所有版本的合約加入channel
function instantiateChaincode(){
  channel_name=$1
  assignPeer=$(head -1 ./peerlist)
  dir=$(ls -l ./../chaincode/ | awk '/^d/ {print $NF}')
  echo
  echo "chaincode實例化..."

  for cc_name in ${dir}
  do
    # 智能合約版本
    vers=$(docker ps -a | grep "dev-${assignPeer}-${cc_name}cc-" | cut -d"-" -f 4)
    # 智能合約版本數量
    END=$(echo ${vers} | wc -l)

    # 在chaincode/ 中的合約，若無實例化產生docker container則跳過，不加入新建立的channel中
    if [ ! -n "${vers}" ]; then
      echo "合約${cc_name} 未曾安裝在peer上，故不將${cc_name} 加入${channel_name}..."
      break
    fi
    
    # 將合約的所有版本都加入新建立的channel中
    for i in $(seq 1 $END); do
      # 合約版本
      version=$(echo ${vers} | cut -d" " -f ${i})
      docker exec cli scripts/script.sh instantiate ${assignPeer} ${cc_name} ${channel_name} ${version}
    done

  done

}


read -p "請輸入要新建立的帳本(channel)名稱: " NEW_CHANNEL

newChannel ${NEW_CHANNEL}
createLedger ${NEW_CHANNEL}
joinChannel ${NEW_CHANNEL}
instantiateChaincode ${NEW_CHANNEL}