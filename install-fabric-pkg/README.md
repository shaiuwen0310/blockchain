# 使用fabric-pkg/自動安裝fabric

### 做法說明
1. 將fabric所需的image及軟體下載下來，並且打包好。執行shell去做安裝。
2. 但就只是安裝上去，fabric的應用還是要手動執行fabric-project裡面的shell。
3. shell-amd64/中放置自動安裝的shell。

---

### fabric-pkg內容
1. 事先將fabric所需軟體都打包放在 fabric-pkg/ 中，如下樹狀圖
   ```
   hi@host:~/fabric-pkg$ tree -L 2
   .
   ├── env.tar
   ├── fabric-1.4.8.tar.gz
   ├── fabric-project.tar.gz
   ├── go1.15.1.linux-amd64.tar.gz
   ├── hyperledger-fabric-linux-amd64-1.4.8.tar.gz
   └── images-amd64
       ├── fabric-baseos.tar
       ├── fabric-ca.tar
       ├── fabric-ccenv.tar
       ├── fabric-couchdb.tar
       ├── fabric-orderer.tar
       ├── fabric-peer.tar
       ├── fabric-tools.tar
       ├── nginx.tar
       └── node.tar
   ```

2. env.tar 就是 installENV 及 installFabric 兩支 shell。

3. 根據不同區塊鏈專案，會有不同的 fabric-pkg 及 installENV、installFabric。

---

### 執行方式
1. 解壓縮env.tar
2. 先執行installENV，再執行installFabric，完成
