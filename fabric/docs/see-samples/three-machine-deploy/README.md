# 多機佈署
- 使用 Hyperledger Fabric 2.2 的範例網路，在三台機器上進行佈署。
- 使用 fabric-pkg/ 安裝三台機器的環境。

## 安裝環境
### 取得fabric-pkg/
- fabric-pkg的Nas路徑：/Public Folder/Project/98_Development/19_fabric2.2應用_LTS-release/02_數位管理系統/

### 上傳fabric-pkg/檔案
```sh
# 第一台
scp -r fabric-pkg/ fabric1@192.168.101.90:/home/fabric1
# 第二台
scp -r fabric-pkg/ fabric2@192.168.101.91:/home/fabric2
# 第三台
scp -r fabric-pkg/ fabric3@192.168.101.92:/home/fabric3
```

### 安裝所需環境
開啟三個terminal視窗，分別登入三台機器後，三台都要做以下指令進行安裝
```sh
cd ~/fabric-pkg

tar xvf env.tar
./installENV.sh

# ./installENV.sh完成後，再執行
sudo reboot
```

### 確認環境已安裝
分別重新登入三台機器

三台都要做以下指令，確認安裝正確，才可進行下一步

```sh
docker ps -a
```
正確情況：
```sh
fabric3@fabric3-SYS-6028R-TR:~$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

### 安裝Hyperledger Fabric 2.2執行檔
三台都要做以下指令進行安裝
```sh
cd ~/fabric-pkg
./installFabric.sh
```
完成後，查看執行檔是否都安裝完成，正確情況：
```sh
fabric1@fabric1-X10DRi:~/fabric-pkg$ docker images
REPOSITORY                   TAG       IMAGE ID       CREATED        SIZE
node                         16.13.0   15ddf4b49c29   7 weeks ago    905MB
nginx                        latest    87a94228f133   2 months ago   133MB
hyperledger/fabric-ca        1.5       4ea287b75c63   3 months ago   69.8MB
hyperledger/fabric-tools     2.2       d32b30082179   3 months ago   429MB
hyperledger/fabric-peer      2.2       4a3aed7a742c   3 months ago   51.8MB
hyperledger/fabric-orderer   2.2       abf523e91319   3 months ago   35.2MB
hyperledger/fabric-ccenv     2.2       96b8a8b006b4   3 months ago   502MB
hyperledger/fabric-baseos    2.2       fb6d7b238996   3 months ago   6.87MB
node                         8.16.0    3d2b7cd190c9   2 years ago    895MB

fabric1@fabric1-X10DRi:~/fabric-pkg$ ll /usr/local/bin/
total 143600
drwxr-xr-x  2 root root     4096 十二 16 11:45 ./
drwxr-xr-x 11 root root     4096 十二 16 11:21 ../
-rwxr-xr-x  1 root root 16665720 十二 16 11:45 configtxgen*
-rwxr-xr-x  1 root root 14852050 十二 16 11:45 configtxlator*
-rwxr-xr-x  1 root root  9739824 十二 16 11:45 cryptogen*
-rwxr-xr-x  1 root root 15153853 十二 16 11:45 discover*
-rwxr-xr-x  1 root root  8856808 十二 16 11:23 docker-compose*
-rwxr-xr-x  1 root root  8464285 十二 16 11:45 idemixgen*
-rwxr-xr-x  1 root root 28243480 十二 16 11:45 orderer*
-rwxr-xr-x  1 root root 45051568 十二 16 11:45 peer*
```

### 下載fabric-samples/
三台都要做以下指令進行下載
```sh
cd ~/go/src/github.com/hyperledger
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.4 1.5.2

ll ~/go/src/github.com/hyperledger/fabric-samples/config
ll ~/go/src/github.com/hyperledger/fabric-samples/bin
```
正確情況：
```
fabric3@fabric3-SYS-6028R-TR:~/go/src/github.com/hyperledger$ ll ~/go/src/github.com/hyperledger/fabric-samples/config
total 88
drwxr-xr-x  2 fabric3 fabric3  4096  九  10 00:07 ./
drwxrwxr-x 31 fabric3 fabric3  4096 十二 16 13:50 ../
-rw-r--r--  1 fabric3 fabric3 25582  九  10 00:06 configtx.yaml
-rw-r--r--  1 fabric3 fabric3 34381  九  10 00:06 core.yaml
-rw-r--r--  1 fabric3 fabric3 15218  九  10 00:06 orderer.yaml

fabric3@fabric3-SYS-6028R-TR:~/go/src/github.com/hyperledger$ ll ~/go/src/github.com/hyperledger/fabric-samples/bin
total 192196
drwxr-xr-x  2 fabric3 fabric3     4096  九  10 03:11 ./
drwxrwxr-x 31 fabric3 fabric3     4096 十二 16 13:50 ../
-rwxr-xr-x  1 fabric3 fabric3 16665720  九  10 00:07 configtxgen*
-rwxr-xr-x  1 fabric3 fabric3 14852050  九  10 00:07 configtxlator*
-rwxr-xr-x  1 fabric3 fabric3  9739824  九  10 00:07 cryptogen*
-rwxr-xr-x  1 fabric3 fabric3 15153853  九  10 00:07 discover*
-rwxr-xr-x  1 fabric3 fabric3 25977096  九  10 03:10 fabric-ca-client*
-rwxr-xr-x  1 fabric3 fabric3 32638416  九  10 03:11 fabric-ca-server*
-rwxr-xr-x  1 fabric3 fabric3  8464285  九  10 00:07 idemixgen*
-rwxr-xr-x  1 fabric3 fabric3 28243480  九  10 00:07 orderer*
-rwxr-xr-x  1 fabric3 fabric3 45051568  九  10 00:07 peer*

```

### 更新docker-compose
三台都要做以下指令進行下載
刪除用fabric-pkg/下載的，因為版本過舊，無法啟動fabric-samples/

```sh
sudo rm /usr/local/bin/docker-compose
```
改成新的docker-compose：
```sh
sudo curl -L https://github.com/docker/compose/releases/download/1.29.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose version
```
新的docker-compose應為1.29.0版
```sh
fabric3@fabric3-SYS-6028R-TR:~/go/src/github.com/hyperledger/fabric-samples/commercial-paper$ docker-compose version
docker-compose version 1.29.0, build 07737305
docker-py version: 5.0.0
CPython version: 3.7.10
OpenSSL version: OpenSSL 1.1.0l  10 Sep 2019
```

### 測試看看fabric-samples/可否使用
三台都要做以下指令進行測試，應要可以啟動

```sh
cd ~/go/src/github.com/hyperledger/fabric-samples
git checkout origin/release-2.2
git branch
# * (HEAD detached at origin/release-2.2)

cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper
# 第一次執行時，會下載`library/busybox`及`library/couchdb`
./network-starter.sh

# ./network-starter.sh成功後，再清除
./network-clean.sh
```
### 以上完成後，表示三台機器可正常執行fabric-samples/

---

## 備份範例專案
### 備份fabric-samples/
三台都要做以下指令進行備份
```sh
cd ~/go/src/github.com/hyperledger
cp -r fabric-samples/ bp_fabric-samples/
cd ~/go/src/github.com/hyperledger/fabric-samples
```

---

## 產生憑證
### 建立orderer憑證
- 使用fabric1@192.168.101.90
- 啟動orderer ca，要先sleep一下讓容器啟動
- 建立orderer憑證
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
# 註解network.sh
# 註解docker/docker-compose-ca.yaml
# 執行./network.sh

# 憑證位置：organizations/ordererOrganizations/
```

### 建立org1憑證
- 使用fabric2@192.168.101.91
- 啟動org1 ca，要先sleep一下讓容器啟動
- 建立org1憑證
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
# 註解network.sh
# network.sh中先不執行organizations/ccp-generate.sh
# 註解docker/docker-compose-ca.yaml
# 執行./network.sh

# 憑證位置：organizations/peerOrganizations/
```

### 建立org2憑證
- 使用fabric3@192.168.101.92
- 啟動org2 ca，要先sleep一下讓容器啟動
- 建立org2憑證
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
# 註解network.sh
# network.sh中先不執行organizations/ccp-generate.sh
# 註解docker/docker-compose-ca.yaml
# 執行./network.sh

# 憑證位置：organizations/peerOrganizations/
```

### 在orderer建立組織憑證的資料夾
- 使用fabric1@192.168.101.90
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network/organizations
mkdir peerOrganizations
```

### 複製org1憑證到orderer
- 使用fabric2@192.168.101.91
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations

scp -r org1.example.com/ fabric1@192.168.101.90:~/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/
```

### 複製org2憑證到orderer
- 使用fabric3@192.168.101.92
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations

scp -r org2.example.com/ fabric1@192.168.101.90:~/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/
```

---

## 建立檔案
### 建立orderer創世區塊
- 使用fabric1@192.168.101.90
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp network.sh bp1_network.sh

# 註解network.sh
# 執行./network.sh

# 創世區塊的檔案位置：system-genesis-block/genesis.block
```

### 建立通道檔案
- 使用fabric1@192.168.101.90
- 在orderer機器上
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp network.sh bp2_network.sh

# 註解network.sh
# 註解scripts/createChannel.sh
# 執行./network.sh

# 通道的檔案位置：channel-artifacts/mychannel.tx
```

## 啟動節點
### 映射ip
三台都要做以下指令進行映射
```sh
sudo vim /etc/hosts
```
往下新增以下內容：
```sh
192.168.101.90 orderer.example.com
192.168.101.91 peer0.org1.example.com
192.168.101.92 peer0.org2.example.com
```

### 啟動orderer節點
- 使用fabric1@192.168.101.90
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp network.sh bp3_network.sh

# 註解network.sh
# 註解docker/docker-compose-test-net.yaml
# 改成FABRIC_LOGGING_SPEC=DEBUG
# 執行./network.sh
```

### 啟動org1的peer節點
- 使用fabric2@192.168.101.91
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp network.sh bp1_network.sh

# 註解network.sh
# 註解docker/docker-compose-test-net.yaml
# 改成FABRIC_LOGGING_SPEC=DEBUG
# 註解docker/docker-compose-couch.yaml
# 執行./network.sh
```

### 啟動org2的peer節點
- 使用fabric3@192.168.101.92
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp network.sh bp1_network.sh

# 註解network.sh
# 註解docker/docker-compose-test-net.yaml
# 改成FABRIC_LOGGING_SPEC=DEBUG
# 註解docker/docker-compose-couch.yaml
# 執行./network.sh
```

### 啟動org1的cli節點
- 使用fabric2@192.168.101.91
- 使用cli對peer下指令
```sh
cd ~/go/src/github.com/hyperledger/bp_fabric-samples/test-network/docker
cp docker-compose-test-net.yaml docker-compose-cli.yaml
mv docker-compose-cli.yaml ../../../fabric-samples/test-network/docker/

cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
# 註解docker/docker-compose-cli.yaml
# 改成FABRIC_LOGGING_SPEC=DEBUG

IMAGETAG=latest
COMPOSE_FILE_BASE=docker/docker-compose-cli.yaml
COMPOSE_FILES="-f ${COMPOSE_FILE_BASE}"
IMAGE_TAG=${IMAGETAG} docker-compose ${COMPOSE_FILES} up -d 2>&1
```

### 啟動org2的cli節點
- 使用fabric3@192.168.101.92
- 使用cli對peer下指令
```sh
cd ~/go/src/github.com/hyperledger/bp_fabric-samples/test-network/docker
cp docker-compose-test-net.yaml docker-compose-cli.yaml
mv docker-compose-cli.yaml ../../../fabric-samples/test-network/docker/

cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
# 註解docker/docker-compose-cli.yaml
# 改成FABRIC_LOGGING_SPEC=DEBUG

IMAGETAG=latest
COMPOSE_FILE_BASE=docker/docker-compose-cli.yaml
COMPOSE_FILES="-f ${COMPOSE_FILE_BASE}"
IMAGE_TAG=${IMAGETAG} docker-compose ${COMPOSE_FILES} up -d 2>&1
```

### 複製通道給各組織
- 使用fabric1@192.168.101.90
- orderer複製通道給org1、org2
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

scp -r channel-artifacts/ fabric2@192.168.101.91:~/go/src/github.com/hyperledger/fabric-samples/test-network/

scp -r channel-artifacts/ fabric3@192.168.101.92:~/go/src/github.com/hyperledger/fabric-samples/test-network/
```

### 複製orderer憑證給各組織
- 使用fabric1@192.168.101.90
- 複製orderer憑證給org1、org2
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

scp -r organizations/ordererOrganizations/ fabric2@192.168.101.91:~/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/

scp -r organizations/ordererOrganizations/ fabric3@192.168.101.92:~/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/
```

### 在org1建立通道區塊
- 使用fabric2@192.168.101.91
- 建立通道檔案，須連線orderer(可查看orderer log)
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp network.sh bp2_network.sh

# 註解network.sh
# 註解scripts/createChannel.sh（localhost為orderer）
# 執行./network.sh

# 產生：channel-artifacts/mychannel.block
```

### 將org1.peer0加入通道
- 使用fabric2@192.168.101.91
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp scripts/createChannel.sh scripts/bp_createChannel.sh

# 註解scripts/createChannel.sh
# 執行./network.sh

# 透過channel-artifacts/mychannel.block加入該通道
```

### org1設定anchor節點
- 使用fabric2@192.168.101.91
- 為通道中的org1設定anchor
- 透過cli操作指令
- 原本cli中內容：
```sh
fabric2@fabric2-SYS-6028R-TR:~/go/src/github.com/hyperledger/fabric-samples/test-network$ docker exec -it cli bash
bash-5.1# ls -al
total 16
drwxr-xr-x    4 root     root          4096 Dec 17 09:59 .
drwxr-xr-x    3 root     root          4096 Dec 17 09:59 ..
drwxrwxr-x    6 1000     1000          4096 Dec 20 02:30 organizations
drwxrwxr-x    3 1000     1000          4096 Dec 20 03:16 scripts
```
指令：
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp scripts/createChannel.sh scripts/bp2_createChannel.sh

# 註解scripts/createChannel.sh
# 執行./network.sh
```
- 後來cli中內容：
```sh
fabric2@fabric2-SYS-6028R-TR:~/go/src/github.com/hyperledger/fabric-samples/test-network$ docker exec -it cli bash
bash-5.1# ls -al
total 204
drwxr-xr-x    4 root     root          4096 Dec 20 03:46 .
drwxr-xr-x    3 root     root          4096 Dec 17 09:59 ..
-rw-r--r--    1 root     root           304 Dec 20 03:46 Org1MSPanchors.tx
-rw-r--r--    1 root     root         46451 Dec 20 03:46 Org1MSPconfig.json
-rw-r--r--    1 root     root         46807 Dec 20 03:46 Org1MSPmodified_config.json
-rw-r--r--    1 root     root         22378 Dec 20 03:46 config_block.pb
-rw-r--r--    1 root     root          2096 Dec 20 03:46 config_update.json
-rw-r--r--    1 root     root           278 Dec 20 03:46 config_update.pb
-rw-r--r--    1 root     root          3642 Dec 20 03:46 config_update_in_envelope.json
-rw-r--r--    1 root     root         10727 Dec 20 03:46 log.txt
-rw-r--r--    1 root     root         18559 Dec 20 03:46 modified_config.pb
drwxrwxr-x    6 1000     1000          4096 Dec 20 02:30 organizations
-rw-r--r--    1 root     root         18503 Dec 20 03:46 original_config.pb
drwxrwxr-x    3 1000     1000          4096 Dec 20 03:46 scripts
```

### org1執行deployCC
- 使用fabric2@192.168.101.91
- 一步步執行deployCC中的步驟
- 有些步驟需要連接orderer
- 只能操作到commitChaincodeDefinition
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp network.sh bp3_network.sh

# 註解./network.sh
# 註解scripts/deployCC.sh（localhost為orderer）
# 註解scripts/envVar.sh（localhost為peer0.org1）
# 執行./network.sh

# 注意：操作到commitChaincodeDefinition步驟 失敗
#（peer lifecycle chaincode commit）
```

### 將org1建立的通道區塊複製到org2
- 使用fabric2@192.168.101.91
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

scp channel-artifacts/mychannel.block fabric3@192.168.101.92:~/go/src/github.com/hyperledger/fabric-samples/test-network/channel-artifacts
```

### 將org2.peer0加入通道
- 使用fabric3@192.168.101.92
- 無須Create channeltx和Create channel
- 只需要做步驟join channel和setAnchorPeer
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

# 註解./network.sh
# 註解scripts/createChannel.sh
# 執行./network.sh

# 透過channel-artifacts/mychannel.block加入該通道
```

### org2設定anchor節點
- 使用fabric3@192.168.101.92
- 為通道中的org2設定anchor
- 透過cli操作指令
- 原本cli中內容：
```sh
fabric3@fabric3-SYS-6028R-TR:~/go/src/github.com/hyperledger/fabric-samples/test-network$ docker exec -it cli bash
bash-5.1# ls -al
total 16
drwxr-xr-x    4 root     root          4096 Dec 17 10:07 .
drwxr-xr-x    3 root     root          4096 Dec 17 10:07 ..
drwxrwxr-x    6 1000     1000          4096 Dec 20 02:31 organizations
drwxrwxr-x    3 1000     1000          4096 Dec 20 08:06 scripts
```
指令：
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp scripts/createChannel.sh scripts/bp2_createChannel.sh

# 註解scripts/createChannel.sh
# 執行./network.sh
```
- 後來cli中內容：
```sh
fabric3@fabric3-SYS-6028R-TR:~/go/src/github.com/hyperledger/fabric-samples/test-network$ docker exec -it cli bash
bash-5.1# ls -al
total 204
drwxr-xr-x    4 root     root          4096 Dec 20 08:08 .
drwxr-xr-x    3 root     root          4096 Dec 17 10:07 ..
-rw-r--r--    1 root     root           304 Dec 20 08:08 Org2MSPanchors.tx
-rw-r--r--    1 root     root         46807 Dec 20 08:08 Org2MSPconfig.json
-rw-r--r--    1 root     root         47163 Dec 20 08:08 Org2MSPmodified_config.json
-rw-r--r--    1 root     root         23471 Dec 20 08:08 config_block.pb
-rw-r--r--    1 root     root          2096 Dec 20 08:08 config_update.json
-rw-r--r--    1 root     root           278 Dec 20 08:08 config_update.pb
-rw-r--r--    1 root     root          3642 Dec 20 08:08 config_update_in_envelope.json
-rw-r--r--    1 root     root         10707 Dec 20 08:08 log.txt
-rw-r--r--    1 root     root         18617 Dec 20 08:08 modified_config.pb
drwxrwxr-x    6 1000     1000          4096 Dec 20 02:31 organizations
-rw-r--r--    1 root     root         18561 Dec 20 08:08 original_config.pb
drwxrwxr-x    3 1000     1000          4096 Dec 20 08:08 scripts
```

### org2執行deployCC
- 使用fabric3@192.168.101.92
- 一步步執行deployCC中的步驟
- 有些步驟需要連接orderer
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp network.sh bp2_network.sh

# 註解./network.sh
# 註解scripts/deployCC.sh（localhost為orderer）
# 註解scripts/envVar.sh（localhost為peer0.org1）
# 執行./network.sh

# 注意：操作到commitChaincodeDefinition步驟 失敗
#（peer lifecycle chaincode commit）
```

### 將org2的憑證複製到org1
- 使用fabric3@192.168.101.92
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

scp -r organizations/peerOrganizations/org2.example.com/ fabric2@192.168.101.91:~/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations
```

### 將org1的憑證複製到org2
- 使用fabric2@192.168.101.91
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

scp -r organizations/peerOrganizations/org1.example.com/ fabric3@192.168.101.92:~/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations
```

### 重新執行：org2執行deployCC的commitChaincodeDefinition步驟
- 使用fabric2@192.168.101.91
- **因為預設沒有ENDORSEMENT_POLICY，所以預設為通道中任何組織成員，故每台機器要有其他人的憑證，以及peer lifecycle chaincode commit要有其他人的憑證路徑**
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

# 註解scripts/deployCC.sh（commitChaincodeDefinition 1 2，因為要兩個組織的憑證）
# 註解scripts/envVar.sh（localhost為peer0.org1和peer0.org2）
# 執行./network.sh
```
完整指令應為：
```sh
+ peer lifecycle chaincode commit -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /home/fabric2/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID mychannel --name basic --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /home/fabric2/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /home/fabric2/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --version 1.0 --sequence 1
```
回應訊息為：
```sh
2021-12-20 17:12:54.652 CST [chaincodeCmd] ClientWait -> INFO 001 txid [42c8a7da69df7ca4c0abd9097c5790ee1a8cce2f42db5535e10d32ee39737933] committed with status (VALID) at peer0.org2.example.com:9051
2021-12-20 17:12:54.895 CST [chaincodeCmd] ClientWait -> INFO 002 txid [42c8a7da69df7ca4c0abd9097c5790ee1a8cce2f42db5535e10d32ee39737933] committed with status (VALID) at peer0.org1.example.com:7051
Chaincode definition committed on channel 'mychannel'
```

### org1執行deployCC
- 使用fabric2@192.168.101.91
- 執行deployCC中的queryCommitted步驟
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network
cp scripts/createChannel.sh scripts/bp3_createChannel.sh

# 註解scripts/deployCC.sh
# 執行./network.sh
```

### 使用peer0.org1執行init
- 使用fabric2@192.168.101.91
- 執行InitLedger
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

export PATH=${PWD}/../bin:$PATH

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

peer chaincode invoke -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
```
查看兩組織的帳本，都有以下內容：
```sh
InitLedger^R<82>^V
<9b>^E
 â¸®<90>È^A!°|6zÚ,µXn°½ûÝ>È,(Ä^Rw³W^^<ÿ^Rö^D
à^D^R6

_lifecycle^R(
&
 namespaces/fields/basic/Sequence^R^B^H^R^R¥^D
^Ebasic^R<9b>^D^ZW
^Fasset1^ZM{"ID":"asset1","color":"blue","size":5,"owner":"Tomoko","appraisedValue":300}^ZT
^Fasset2^ZJ{"ID":"asset2","color":"red","size":5,"owner":"Brad","appraisedValue":400}^ZZ
^Fasset3^ZP{"ID":"asset3","color":"green","size":10,"owner":"Jin Soo","appraisedValue":500}^ZW
^Fasset4^ZM{"ID":"asset4","color":"yellow","size":10,"owner":"Max","appraisedValue":600}^ZZ
^Fasset5^ZP{"ID":"asset5","color":"black","size":15,"owner":"Adriana","appraisedValue":700}^ZY
^Fasset6^ZO{"ID":"asset6","color":"white","size":15,"owner":"Michel","appraisedValue":800}^Z^C^HÈ^A"^L^R^Ebasic^Z^C1.0^R±^H
å^G
```

### 使用peer0.org2查詢資訊
- 使用fabric3@192.168.101.92
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

export PATH=${PWD}/../bin:$PATH

export FABRIC_CFG_PATH=$PWD/../config/

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051

peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```
查詢結果
```js
[{"ID":"asset1","color":"blue","size":5,"owner":"Tomoko","appraisedValue":300},{"ID":"asset2","color":"red","size":5,"owner":"Brad","appraisedValue":400},{"ID":"asset3","color":"green","size":10,"owner":"Jin Soo","appraisedValue":500},{"ID":"asset4","color":"yellow","size":10,"owner":"Max","appraisedValue":600},{"ID":"asset5","color":"black","size":15,"owner":"Adriana","appraisedValue":700},{"ID":"asset6","color":"white","size":15,"owner":"Michel","appraisedValue":800}]
```

### 使用peer0.org2修改資訊
- 使用fabric3@192.168.101.92
- 將"key":"asset6"的"owner"從"Michel"改成"Christopher"
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

export PATH=${PWD}/../bin:$PATH

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

peer chaincode invoke -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}'
```
回應結果
```sh
2021-12-21 09:46:52.202 CST [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200 
```

### 使用peer0.org1查詢資訊
- 使用fabric2@192.168.101.91
- 查詢asset6資訊
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/test-network

export PATH=${PWD}/../bin:$PATH

export FABRIC_CFG_PATH=$PWD/../config/

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

peer chaincode query -C mychannel -n basic -c '{"Args":["ReadAsset","asset6"]}'
```
查詢結果
```js
{"ID":"asset6","color":"white","size":15,"owner":"Christopher","appraisedValue":800}
```

---

## summary
先討論網路收斂的方向，再測試使用SDK
### 情境
- 啟用基本網路，每個組織各有ca-server建立憑證
- 安裝的合約應用類似orderform
- 僅區塊鏈網路，無SDK部份
### 安裝狀況
- 新步驟：**不熟悉**
  - ca-server產生組織憑證，並分別產在不同機器上
  - 節點啟動後，產生各組織的anchor檔案的步驟，跟之前的example不一樣
  - 使用預設ENDORSEMENT_POLICY，但我們指定ENDORSEMENT_POLICY為單一組織的成員
  - 安裝流程大部份使用binary完成，我們使用cli全部完成
- 步驟
  - 三台機器分別啟動各自的ca-server，再分別建立各自的orderer憑證、建立org1憑證、建立org2憑證
  - 複製peer0.org1、peer0.org2憑證給orderer機器（orderer需要所有組織的憑證**路徑**，才可以產生排序設定檔的創世區塊）
  - 在orderer機器建立創世區塊、通道檔案（genesis.block、mychannel.tx）
  - 每台機器都映射節點ip（但一台機器多節點，要如何設定？）
  - 三台機器分別啟動orderer節點、peer0.org1節點、peer0.org2節點
  - 在org1、org2機器上，啟動各自的cli節點，各自的cli會有各自的環境變數
  - orderer機器複製通道檔案（mychannel.tx）給org1、org2機器
  - 複製orderer憑證給org1、org2機器（在peer lifecycle chaincode的指令操作中，需要orderer憑證**路徑**）
  - 在org1機器建立通道區塊（mychannel.tx -> mychannel.block），並將通道區塊複製給org2機器
  - 在org1機器上，將peer0.org1節點加入通道、透過cli設定anchor、打包合約、安裝合約、org1組織同意合約
  - 在org2機器上，將peer0.org1節點加入通道、透過cli設定anchor、打包合約、安裝合約、org2組織同意合約
  - 使org1及org2機器互相擁有彼此的peer節點憑證
    - 原因為下一點，也許跟透過SDK操作的方式不同
  - 在org2機器提交合約給通道，須使用所有組織的憑證
    - 安裝過程中，未指定背書策略（ENDORSEMENT_POLICY）
      - 背書策略默認為：通道中組織的任何成員
      - 在任一台下指令時，需要其他台的憑證
      - 若每個組織的背書策略為各自組織成員，或任意組織成員，可能就只需要該台機器的憑證？
      - [[待討論此議題]ENDORSEMENT_POLICY](https://192.168.2.246/digital-assets-management/consortium-blockchain/-/issues/11) ：**不熟悉**
  - 以上完成佈署區塊鏈完整網路
### 測試狀況
- 使用指令測試，非SDK
  - 使用peer binary下指令操作，而不是透過cli容器下指令
  - 要設定好環境變數
- 所有組織都需要orderer的憑證**路徑**，才可以進行query和invoke(invoke可能需要所有組織的憑證**路徑**)
- 安裝過程中，未指定背書策略，因此在任一台下指令時，需要其他台的憑證
### 代辦事項
- ENDORSEMENT_POLICY
- 順啟動網路的流程，包含產生檔案、啟動節點
- 檔案複製方式？
- /etc/hosts設定方式？設定anchor的hostname？
- 了解anchor產生設定，ca-server產生哪些檔案
- 有些地方寫使用cli，有些地方寫以後不使用

