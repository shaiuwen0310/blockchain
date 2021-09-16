# 自動安裝fabric

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

3. 根據不同區塊鏈專案，會有不同的 fabric-pkg 及 env.tar。

---

