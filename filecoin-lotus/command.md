# Filecoin Lotus Command

## 介紹

根據[lotus官方操作手冊](https://docs.lotu.sh/)安裝lotus，Lotus為官方Filecoin之實現。

## __lotus__

### __lotus chain__

與filecoin區塊鏈交互：如抓取block資訊、DAG node、讀取物件的raw data等

### __lotus client__

進行交易、存儲數據、檢索數據

### __lotus msig__

與多重簽名錢包互動

### __lotus net__

p2p網路管理：如顯示peers、連接peer、列出listen addresses、Get node id等

### __lotus paych__

與filecoin鏈狀態的交互和查詢　`用到的時機？`

### __lotus send__

賬戶間轉賬

### __lotus state__

與filecoin鏈狀態的交互和查詢：

lotus state `power`：查詢全網算力或礦機算力、

lotus state `sectors`：查詢礦機的扇區集、

lotus state `proving`：查詢一個礦機的證明集、

lotus state `pledge-collateral`：獲得最低限度的礦機抵押、

lotus state `list-actors`：列出網絡中的所有角色、

lotus state `list-miners`：列出網絡中的所有礦工、

lotus state `get-actor`：打印角色信息、

lotus state `lookup`：查找對應的 ID 地址、

lotus state `replay`：在tipset中重放特定消息、

lotus state `sector-size`：查看礦機的扇區規格、

lotus state `read-state`：查看角色狀態的 json 表示、

lotus state `list-messages`：列出與給定條件匹配的鏈上的消息

### __lotus sync__

檢查或與鏈同步器交互：

lotus sync `status`：	檢查同步狀態、

lotus sync `wait`：等待同步完成、

lotus sync `mark-bad`：將給定的塊標記爲 bad，將阻止包含此塊的 xxx 同步到鏈、

lotus sync `check-bad`：檢查給定塊是否被標記爲壞塊，原因是什麼、

### __lotus wallet__

管理錢包：如列出帳號、查餘額、ex/import key、set/get default wallet addr

### __lotus log__

管理日誌：如列出日誌系統、設置日誌系統的日誌級別


