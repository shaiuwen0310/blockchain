#!/bin/bash

# 
# 執行時的流程
#   1. startNode：啟動區塊鏈網路節點docker container(5個orderer、2個peer、1個ca、1個cli)
#   2. createLedger：使用generate.sh產生的*.tx檔案來建立帳本，可在orderer中發現其檔案(orderer容器中的帳本路徑：/var/hyperledger/production/orderer/chains)
#   3. joinChannel：將peer加入channel中，可在peer中發現與orderer內容一樣的帳本(peer容器中的帳本路徑：/var/hyperledger/production/ledgersData/chains/chains)
#   4. installChaincode：將智能合約安裝在所有peer上，可在peer中看見合約(peer容器中的帳本路徑：/var/hyperledger/production/chaincodes)
#   5. installChaincode：挑選任一peer，在所有channel中進行合約實例化
# 

# 啟動節點
function startNode() {
  echo "====== 開始啟動區塊鏈網路節點 ======"
  echo
  COMPOSE_FILES="-f ${COMPOSE_FILE} -f ${COMPOSE_FILE_CA} -f ${COMPOSE_FILE_ORDERER}"
  export BYFN_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/ca && ls *_sk)

  docker-compose ${COMPOSE_FILES} up -d 2>&1
  docker ps -a
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! 無法啟動網路..."
    exit 1
  fi

  sleep 1
  echo "15秒鐘等待orderer啟動..."
  sleep 14

  # 透過cli對peer下指令用，啟動時預設連接peer0
  # 等peer orderer都啟動後，再啟動cli
  # 為了避免重起peer時，cli的depends_on設定造成異常，peer及cli的檔案需要分開
  docker-compose -f ${COMPOSE_FILE_CLI} up -d 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! 無法啟動cli..."
    exit 1
  fi

  # 紀錄peer容器名稱
  peerlist=$(docker ps --format '{{.Names}}' | grep 'peer')
  echo "${peerlist}" > peerlist
  echo "====== 完成啟動區塊鏈網路節點 ======"
  echo
}

# 建立帳本(channel)
function createLedger(){
  FILENAME=genlist
  for i in `cat $FILENAME`
  do
    echo "建立${i}帳本..."
    docker exec cli scripts/script.sh createchannel "" "" $i
    sleep 3
  done
}

# 將所有peer加入當前帳本(channel)中
function joining(){
  channel_name=$1
  FILENAME=peerlist
  for peer_name in `cat $FILENAME`
  do
    docker exec cli scripts/script.sh joinchannel ${peer_name} "" ${channel_name} ""
    sleep 3
  done
}

# peer加入channel，使peer接收在channel上的資訊
function joinChannel(){
  echo
  echo "將peer加入channel中..."

  FILENAME=genlist
  for channel_name in `cat $FILENAME`
  do
    joining ${channel_name}
  done
}

function installing(){
  ccname=$1
  FILENAME=peerlist
  for i in `cat $FILENAME`
  do
  # 第一次安裝合約 都是1.0
    docker exec cli scripts/script.sh install $i ${ccname} "" "1.0"
    sleep 3
  done
}

# 將智能合約安裝在所有peer上
function installChaincode(){
  if [ ! -f "./../chaincode/rcc" ]; then
    echo
    echo "尚未有chaincode被安裝...開始將chaincode安裝在peer上..."
    dir=$(ls -l ./../chaincode/ | awk '/^d/ {print $NF}')
    for i in $dir
    do
      installing $i
    done
  fi
}

# 實例化合約，也可以說是將合約加入channel
function instantiateChaincode(){
  dir=$(ls -l ./../chaincode/ | awk '/^d/ {print $NF}')
  assignPeer=$(head -1 ./peerlist)
  echo
  echo "chaincode實例化..."
  for cc_name in ${dir}
  do
    FILENAME=genlist
    for channel_name in `cat $FILENAME`
    do
      docker exec cli scripts/script.sh instantiate ${assignPeer} ${cc_name} ${channel_name} "1.0"
      sleep 3
    done

    # 只要經過實例化，一律記錄合約名稱
    # 若執行start.sh實例化失敗，請一律全部刪除，並重新建立
    echo "${cc_name}" >> ./../chaincode/rcc
  done
}


if [ ! -d "crypto-config" ]; then
  echo "請先執行generate.sh..."
  exit 1
fi

# 設定檔
COMPOSE_FILE=docker-compose-peer.yaml
COMPOSE_FILE_ORDERER=docker-compose-orderer.yaml
COMPOSE_FILE_CA=docker-compose-ca.yaml
COMPOSE_FILE_CLI=docker-compose-cli.yaml

if [ -f "peerlist" ]; then
  echo "已執行過start.sh並且未刪除，請確認..."
  exit 1
fi

startNode
createLedger
joinChannel
installChaincode
instantiateChaincode
