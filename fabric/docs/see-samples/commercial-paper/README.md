# Commercial-paper-tutorial
## 說明
- 照著文件測試不成功，要跟著Commercial-paper的README.md來執行
- fabric-ca-client SDK，可以引用fabric-ca-client binary建立的憑證私鑰，來產生walletID，並且同一組憑證私鑰可產生多個walletID
## 操作步驟
* **下載fabric-samples/**
```sh
cd ~/go/src/github.com/hyperledger/
git clone https://github.com/hyperledger/fabric-samples.git
cd ~/go/src/github.com/hyperledger/fabric-samples
git branch -r
git checkout origin/release-2.2
git branch
```
記得要加上下面兩個資料夾：
```sh
judy@l:~/go/src/github.com/hyperledger/fabric-samples$ tree -L 2
.
...
├── bin
│   ├── configtxgen
│   ├── configtxlator
│   ├── cryptogen
│   ├── discover
│   ├── fabric-ca-client
│   ├── fabric-ca-server
│   ├── idemixgen
│   ├── orderer
│   └── peer
...
├── config
│   ├── configtx.yaml
│   ├── core.yaml
│   └── orderer.yaml
```
* **啟動範例網路**
```sh
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper
./network-starter.sh
```
* **新開視窗給magnetocorp使用**
	* 開啟新的terminal
	* 設定magnetocorp組織的環境變數
```sh
# magnetocorp

# 在新的terminal下操作
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp
. ./magnetocorp.sh
```
* **新開視窗給digibank使用**
	* 開啟新的terminal
	* 設定digibank組織的環境變數
```sh
# digibank

# 在新的terminal下操作
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank
. ./digibank.sh
```
* **在magnetocorp的視窗操作**
  * 打包合約
  * 安裝合約
  * 允許合約在magnetocorp所屬的組織中執行
  * 檢查合約可否被commit到通道上
```sh
# MAGNETOCORP
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp

peer lifecycle chaincode package cp.tar.gz --lang node --path ./contract --label cp_0
peer lifecycle chaincode install cp.tar.gz

export PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r '.installed_chaincodes[0].package_id')

peer lifecycle chaincode approveformyorg  --orderer localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
                                          --channelID mychannel  \
                                          --name papercontract  \
                                          -v 0  \
                                          --package-id $PACKAGE_ID \
                                          --sequence 1  \
                                          --tls  \
                                          --cafile $ORDERER_CA
                                          
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name papercontract -v 0 --sequence 1
```
* **在digibank的視窗操作**
  * 打包合約
  * 安裝合約
  * 允許合約在magnetocorp所屬的組織中執行
  * 檢查合約可否被commit到通道上
```sh
# DIGIBANK
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank

peer lifecycle chaincode package cp.tar.gz --lang node --path ./contract --label cp_0
peer lifecycle chaincode install cp.tar.gz

export PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r '.installed_chaincodes[0].package_id')

peer lifecycle chaincode approveformyorg  --orderer localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
                                          --channelID mychannel  \
                                          --name papercontract  \
                                          -v 0  \
                                          --package-id $PACKAGE_ID \
                                          --sequence 1  \
                                          --tls  \
                                          --cafile $ORDERER_CA

peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name papercontract -v 0 --sequence 1
```
* **在任意組織進行操作**
  * 此處在magnetocorp進行操作
  * 將合約commit到通道上進行使用
```sh
# MAGNETOCORP
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp

peer lifecycle chaincode commit -o localhost:7050 \
                                --peerAddresses localhost:7051 --tlsRootCertFiles ${PEER0_ORG1_CA} \
                                --peerAddresses localhost:9051 --tlsRootCertFiles ${PEER0_ORG2_CA} \
                                --ordererTLSHostnameOverride orderer.example.com \
                                --channelID mychannel --name papercontract -v 0 \
                                --sequence 1 \
                                --tls --cafile $ORDERER_CA --waitForEvent
```
* **使用指令測試看看**
```sh
# MAGNETOCORP
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp

#
peer chaincode invoke -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com \
                                --peerAddresses localhost:7051 --tlsRootCertFiles ${PEER0_ORG1_CA} \
                                --peerAddresses localhost:9051 --tlsRootCertFiles ${PEER0_ORG2_CA} \
                                --channelID mychannel --name papercontract \
                                -c '{"Args":["org.papernet.commercialpaper:instantiate"]}' ${PEER_ADDRESS_ORG1} ${PEER_ADDRESS_ORG2} \
                                --tls --cafile $ORDERER_CA --waitForEvent

#
peer chaincode query -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com \
                                        --channelID mychannel \
                                        --name papercontract \
                                        -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}' \
                                        --peerAddresses localhost:9051 --tlsRootCertFiles ${PEER0_ORG2_CA} \
                                        --tls --cafile $ORDERER_CA | jq '.' -C | more
```
* **建立應用程式的環境**
	* magnetocorp及digibank分別有自己的應用
	  * 分別安裝node_modules/
	  * 分別建立walletID
```sh
# MAGNETOCORP
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application

npm install

# node enrollUser.js
node addToWallet.js
```
```sh
# DIGIBANK
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application

npm install

# node enrollUser.js
node addToWallet.js
```
* **透過應用程式執行Commercial-paper的情境**
  * 由MagnetoCorp發行票據00001
  * 由Digibank購買票據00001
  * DigiBank 從 MagnetoCorp 那裡贖回商業票據00001
```sh
# 步驟一：由MagnetoCorp發行票據00001

# MAGNETOCORP
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application
node issue.js
```
```sh
# 步驟二：由Digibank購買票據00001

# DIGIBANK
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application
node buy.js
```
```sh
# 步驟三：DigiBank 從 MagnetoCorp 那裡贖回商業票據00001

# DIGIBANK
cd ~/go/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application
node redeem.js
```
* **DB中的狀況**
  * 在couchDB中，該筆票據的屬性
  * key值：`org.papernet.paperMagnetoCorp00001`
  * couchDB url：http://127.0.0.1:5984/_utils
```js
// 步驟一：由MagnetoCorp發行票據00001

id"org.papernet.paperMagnetoCorp00001"
{
 "id": "\u0000org.papernet.paper\u0000MagnetoCorp\u000000001\u0000",
 "key": "\u0000org.papernet.paper\u0000MagnetoCorp\u000000001\u0000",
 "value": {
  "rev": "1-788ba019bb243d8910a2ab1fec88f9f6"
 },
 "doc": {
  "_id": "\u0000org.papernet.paper\u0000MagnetoCorp\u000000001\u0000",
  "_rev": "1-788ba019bb243d8910a2ab1fec88f9f6",
  "class": "org.papernet.commercialpaper",
  "currentState": 1,
  "faceValue": 5000000,
  "issueDateTime": "2020-05-31",
  "issuer": "MagnetoCorp",
  "maturityDateTime": "2020-11-30",
  "mspid": "Org2MSP",
  "owner": "MagnetoCorp",
  "paperNumber": "00001",
  "~version": "CgMBCAA="
 }
}
```
```js
// 步驟二：由Digibank購買票據00001

id"org.papernet.paperMagnetoCorp00001"
{
 "id": "\u0000org.papernet.paper\u0000MagnetoCorp\u000000001\u0000",
 "key": "\u0000org.papernet.paper\u0000MagnetoCorp\u000000001\u0000",
 "value": {
  "rev": "2-016cce7e3656f712ed49650707cd1818"
 },
 "doc": {
  "_id": "\u0000org.papernet.paper\u0000MagnetoCorp\u000000001\u0000",
  "_rev": "2-016cce7e3656f712ed49650707cd1818",
  "class": "org.papernet.commercialpaper",
  "currentState": 3,
  "faceValue": 5000000,
  "issueDateTime": "2020-05-31",
  "issuer": "MagnetoCorp",
  "maturityDateTime": "2020-11-30",
  "mspid": "Org1MSP",
  "owner": "DigiBank",
  "paperNumber": "00001",
  "~version": "CgMBCQA="
 }
}
```
```js
// 步驟三：DigiBank 從 MagnetoCorp 那裡贖回商業票據00001

id"org.papernet.paperMagnetoCorp00001"
{
 "id": "\u0000org.papernet.paper\u0000MagnetoCorp\u000000001\u0000",
 "key": "\u0000org.papernet.paper\u0000MagnetoCorp\u000000001\u0000",
 "value": {
  "rev": "3-918f530d85b06ef028fbf9c87f54d392"
 },
 "doc": {
  "_id": "\u0000org.papernet.paper\u0000MagnetoCorp\u000000001\u0000",
  "_rev": "3-918f530d85b06ef028fbf9c87f54d392",
  "class": "org.papernet.commercialpaper",
  "currentState": 4,
  "faceValue": 5000000,
  "issueDateTime": "2020-05-31",
  "issuer": "MagnetoCorp",
  "maturityDateTime": "2020-11-30",
  "mspid": "Org2MSP",
  "owner": "MagnetoCorp",
  "paperNumber": "00001",
  "redeemDateTime": "2020-11-30",
  "~version": "CgMBCgA="
 }
}
```

