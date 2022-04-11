# 匯出docker-images
## 說明
* 匯出fabric相關的docker images
* 根據每次使用環境不同，shell需要調整
* 執行後，會在同路徑下建立資料夾，並放置匯出的images

## 調整內容
* 版本變數
```
FABRIC_TAG=2.2
FABRIC_CA_TAG=1.5
```
* 需要匯出的docker images名稱
```sh
docker save hyperledger/fabric-ca:${FABRIC_CA_TAG} > ${EXPORT_FOLDER}/fabric-ca-${FABRIC_CA_TAG}.tar
```
