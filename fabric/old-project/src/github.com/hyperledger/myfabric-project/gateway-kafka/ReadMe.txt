打包api服務:
1. 確認wallet為空，若有identity須先清空
2. 在node-api-service/下cmd: docker build -f snsrdata-Dockerfile -t snsrdata .

啟動網路:
在fabric-network/network/下cmd: 
./clearup.sh
./generate.sh
./start.sh

啟動服務:
在node-api-service/下cmd:
./runApp.sh，自動替換networkConnection.yaml中的node名稱及IP，再開啟服務

建立walletID:
分別將genid/id-testAPI.sh中的enrollAdmin和registerUser註解移除
在node-api-service/下cmd:
./id-testAPI.sh
將genid/id-testAPI.sh中的enrollAdmin和registerUser註解恢復

若無gin要先安裝:
go get -u github.com/gin-gonic/gin

在receiver/下cmd:
go build

在other-server/下cmd:
go build

在/etc/rc.local設定執行autoRestart.sh指令

調整開機自動啟動other-server:
cd  /lib/systemd/system
sudo vim other-server.service
內容複製other-serviceCTL 路徑要針對不同server進行調整
reloadsystemd的配置清單: systemctl daemon-reload
列舉所有已經存在設定檔對應的服務狀態清單: systemctl list-unit-files | grep other-server
啟動: systemctl start other-server.service
開機自動啟動: systemctl enable other-server.service

調整開機自動啟動receiver:
cd  /lib/systemd/system
sudo vim iotdataT.timer
sudo vim iotdata.service
內容複製receiverCTL 路徑要針對不同server進行調整
reloadsystemd的配置清單: systemctl daemon-reload
列舉所有已經存在設定檔對應的服務狀態清單: systemctl list-unit-files | grep iotdataT
啟動: systemctl start iotdataT.timer
開機自動啟動: systemctl enable iotdataT.timer

將receiver中所有路徑設定judy改tim

執行交易:
receiver設定192.168.101.16
iot sensor設定192.168.101.17
ezserver2顯示畫面192.168.101.251:8001

iot sensor -> receiver -> ezserver2

結束操作:
1. 於node-api-service/下刪除服務容器: ./downApp.sh
2. 於fabric-network/network/下刪除網路容器: ./down.sh
3. 於fabric-network/network/下清空網路及相關檔案: ./clearup.sh
4. 於node-api-service/下清空ID: sudo刪除wallet中的檔案 rm -rf *
