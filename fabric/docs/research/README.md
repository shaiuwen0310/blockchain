# 查找記錄
## 使用fabric-2.2當下找的資訊
### 合約api的狀況
* 合約新api：不使用新的[fabric-contract-api-go](https://github.com/hyperledger/fabric-contract-api-go)，查詢[fabric-chaincode-go](https://github.com/hyperledger/fabric-chaincode-go)的API，進行中
  * `帳本狀態交互API` 範例：[marbles_chaincode.go](https://github.com/hyperledger/fabric/blob/release-1.4/examples/chaincode/go/marbles02/marbles_chaincode.go)，對應書本p231
  * 調用其他鏈碼 範例：[passthru.go](https://github.com/hyperledger/fabric/blob/release-1.4/examples/chaincode/go/passthru/passthru.go)，對應書本p240，未用到
  * 交易訊息API 範例：未找到
  * `控制權限`(客戶端身份庫：獲取調用者的msp身份) 範例：[abac.go](https://github.com/hyperledger/fabric-samples/blob/release-1.4/chaincode/abac/go/abac.go)
    * 要注意shim中的`cid`改位置：[url](https://github.com/hyperledger/fabric-chaincode-go/tree/release-2.2/pkg/cid)，對應書本p242
    * `但看起來只能使用getMSPID，因為屬性及NodeUS目前專案沒有設定(看起來是使用ca服務做屬性設定: --id.attrs 'app1Admin=true:ecert,email=user1@gmail.com')`
    * `import cid參考`：[asset_transfer_test.go](https://github.com/hyperledger/fabric-samples/blob/2b662e08b45b9cfadda23cc5da3bdf83d0be9d2e/asset-transfer-private-data/chaincode-go/chaincode/asset_transfer_test.go)
    * [Hyperledger Fabric实践：供应链金融案例_oXiaoBuDing的博客-程序员宅基地](https://www.cxyzjd.com/article/oXiaoBuDing/84655511)
    * 在合約中做身份判別 範例：[Performing multiple operations more efficiently](https://github.com/hyperledger/fabric-chaincode-go/tree/release-2.2/pkg/cid)

### 看test-network-k8s範例
* 都是在shell下指令、節點之變數
* ca分msp和tls的節點
* 設定檔使用configmap打包給pod使用, 包含orderer.yaml core.yaml ccp.json等等
* 自行設置FABRIC_CFG_PATH, 但images預設有
* 使用服務名稱時都沒有加上port號
* 另外抓出所需msp等憑證放入configmap, 給rest-api使用(hyperledgendary/fabric-rest-sample)
* 一個組織一個pv(/var/hyperledger/org2.example.com)
* 文件描述, `重新建立共識並更新證書是不可能的`[Planning for a CA](https://github.com/hyperledger/fabric-samples/blob/main/test-network-k8s/docs/CA.md#planning-for-a-ca)
* 使用ca建立屬性(--id.affiliation --id.attrs), 讓合約中可以獲取這些屬性, 去限定這些屬性可執行合約
* TLS證書不是指向文件夾，不需要像本地 MSP 那樣保存在嚴格的文件夾結構中
* 憑證流程應該是, 組織中自己建置完, 再把憑證提供到共用資料夾中

### images設定檔和備份之預設路徑
* ca
```
/etc/hyperledger/fabric-ca-server # ls 
IssuerPublicKey   IssuerRevocationPublicKey   fabric-ca-server-config.yaml   fabric-ca-server.db   msp/
```
* peer
```
/var/hyperledger/production # ls
chaincodes/   externalbuilder/   ledgersData/   lifecycle/   transientstore/

/etc/hyperledger/fabric # ls
core.yaml/  msp/  tls/

```
* orderer
```
/var/hyperledger/production # ls
orderer/

/var/hyperledger/production/orderer # ls
chains/   etcdraft/   index/

/etc/hyperledger/fabric # ls
configtx.yaml   msp/   orderer.yaml
```
