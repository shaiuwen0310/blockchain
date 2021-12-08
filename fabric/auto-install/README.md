# 自動安裝環境
## 說明
* 建立一個fabric-pkg/資料夾，內容如下樹狀圖
	* `env.tar` 為自動安裝腳本：installENV.sh 及 installFabric.sh
	* `fabric-project.tar.gz` 為專案應用
```
.
└── fabric-pkg
    ├── env.tar
    ├── fabric-2.2.4.tar.gz
    ├── fabric-project.tar.gz
    ├── go1.15.1.linux-amd64.tar.gz
    ├── hyperledger-fabric-linux-amd64-2.2.4.tar.gz
    └── images-amd64
        ├── fabric-baseos-2.2.tar
        ├── fabric-ca-1.5.tar
        ├── fabric-ccenv-2.2.tar
        ├── fabric-orderer-2.2.tar
        ├── fabric-peer-2.2.tar
        ├── fabric-tools-2.2.tar
        ├── nginx-latest.tar
        ├── node-16.13.tar
        ├── node-8.16.tar
```
* 當拿到 `fabric-pkg` 時，解開env.tar，先執行installENV.sh 再執行 installFabric.sh，即可安裝環境完成

