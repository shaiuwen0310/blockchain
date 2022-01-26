# 重點記錄

## 方向目標

1. 不同部門建立ipfs私有節點，A部門上傳檔案後，即使A部門關閉節點，B部門還是可以找得到檔案
2. 方向為節省硬碟空間，因此不會將一份資料同步給所有節點
3. 從desktop to server (大概是私有節點中有desktop可以使用)
4. ipfs + 區塊鏈

------------------

## [IPFS官網](https://ipfs.io/)

### 桌面版
* 指令較Command line少
* experimental installer for Linux and FreeBSD
* `以下操作測試，皆採用deb方式安裝`

### Command-line版
* 使用go-ipfs
* `最新release為0.6`，包含對IPFS協議的重大更改
* release 0.6需要使用`go 1.4.4`或以上
* 亦可使用docker
* `以下操作測試，皆使用linux安裝`

### JS實作(尚未接觸過)
* 帶有一些瀏覽器獨有的額外功能
*  所有d-App的toolkit

### 透過瀏覽器查看ipfs中檔案的[套件](https://docs.ipfs.io/install/command-line-quick-start/#ipfs-companion)
* 透過ipfs提供的gateway服務，將URL換成`https://ipfs.io/ipfs/<CID>`，使瀏覽器可閱覽`/ipfs/<CID>`
* Cloudflare提供ipfs gateway相關服務

### [ipfs分佈式管理工具](https://cluster.ipfs.io/)
* 同時管理多個ipfs節點的數據，自動同步數據到所有ipfs節點上
* 亦可將節點轉為私有
* 操作測試後才發現`不符合方向目標`，故後續不做描述
------------------

## 安裝ipfs節點

1. 皆於ubuntu安裝測試
2. 首先要`安裝go1.14.4`
3. 安裝完ipfs節點後，也一併安裝[IPFS Companion](https://docs.ipfs.io/how-to/command-line-quick-start/#ipfs-companion)

*Notes:* 重安裝一定要`先將資料夾移除乾淨`

### 安裝桌面版
* 下載deb package檔案後，輸入下列指令來安裝，完成後即可看到icon
    ```sh
    sudo dpkg -i ipfs-desktop-0.11.4-linux-amd64.deb
    ```
* 啟動ipfs-desktop後才會出現下列資料夾
    ```
    ~/.ipfs-desktop/
    ~/.ipfs/
    ~/.config/IPFS Desktop
    ```
* 桌面版ipfs執行檔的位置
    ```
    /opt/IPFS Desktop/resources/app.asar.unpacked/node_modules/go-ipfs-dep/go-ipfs
    ```

### 安裝Command-line
* 依照[Command-line quick start](https://docs.ipfs.io/how-to/command-line-quick-start/)進行安裝
* 安裝好後，如同quick start上的Initialize the repository，進行初始化
    ```sh
    # 若是私有節點，應不需設成ipfs init --profile server
    ipfs init
    ```
* init後才會出現下列資料夾
    ```
    ~/.ipfs/
    ```
* 可進行設定檔調整，如修改預設的暫存大小，參考[The go-ipfs config file](https://github.com/ipfs/go-ipfs/blob/master/docs/config.md)
------------------

## 刪除ipfs節點

1. 皆於ubuntu安裝測試

### 刪除桌面版
* 安裝Synaptics Package Manager
    ```
    sudo apt-get install synaptic
    ```
* 搜尋ipfs，就會看到其.deb檔案
* 點擊並選擇Mark for Removal
* 點擊移除Apply
* 移除資料夾
    ```
    ~/.ipfs-desktop/
    ~/.ipfs/
    ~/.config/'IPFS Desktop'
    ```

### 刪除Command-line版
* 移除binary
* 移除資料夾
    ```
    ~/.ipfs/
    ```
------------------

## 遇到的問題

### 操作問題

1. 上傳檔案到ipfs-desktop後，使用sharelink，瀏覽器上呈現timeout
    ```
    1.1. 要安裝瀏覽器套件
    1.2. 兩台電腦皆安裝ipfs及瀏覽器plugin，就可以透過檔案的sharelink看到對方電腦上的檔案
    ```

2. 一台電腦上同時安裝 桌面版 和 Command-line版
    ```
    2.1. 上傳資料需要以桌面版為準
    2.2. Command-line版可上傳重複資料夾，桌面版則需要先刪除檔案才可以再次上傳
    2.3. Command-line版可以抓到桌面版上傳的資料，但桌面版無法看到Command-line版上傳的資料
    ```

3. `從ipfs-desktop上下載的資料夾，無法開啟` ⚠ ⚠ ⚠ 

### 觀念問題
* IPFS將所有數據存儲在哪裡？
    1. 所有blocks也存儲在我的系統本地嗎？
        ```
        是，上傳檔案時，檔案就會被分成多塊blocks，並存儲在緩存文件夾（~/.ipfs）中
        ```
    2. 數據還存儲在哪裡？關閉ipfs節點，仍然可以訪問該文件？
        ```
        2.1. 在其他ipfs節點上查看該檔案，則該ipfs節點會請求檔案並對其進行緩存
        2.2. 仍可能在網關上看到該文件，可能是因為網關或Web上的其他peers仍對其進行了緩存
        ```
    3. 數據存儲在多個ipfs節點中，如果所有ipfs節點都斷線，丟失的檔案仍然存在嗎？
        ```
        當無法再從已緩存了一部分文件的所有ipfs節點(包括自己)重新構造文件時，就會丟失文件
        ```
    4. 網絡上的每個ipfs節點都存儲整個文件還是僅存儲文件的一部分？
        ```
        一個人只能得到其中的一部分
        ```
    5. 我們也存儲其他peers上傳的數據嗎？
        ```
        如果獲取數據，則將其緩存
        ```
* IPFS緩存預設10GB，當要下載文件但內存不足(無法再緩存)時，最舊使用的文件會被忘記釋放空間
    ```sh
    # 設定緩存大小
    ipfs config Datastore.StorageMax 1GB
    ```
------------------

## 建立ipfs私有網路

1. 設置三台ipfs節點
2. 其中一台會設置成bootstrap

### 在每一台都[安裝ipfs節點](#安裝ipfs節點)

* 記得安裝go1.14.4
* 一台使用桌面版，另兩台為Command-line版

### 啟動三台ipfs節點

* 桌面版為開啟icon

* Command-line版為執行下列命令
    ```sh
    ipfs deamon
    ```

### 產生swarm.key

* 三個節點都使用同一個swarm.key才有辦法互連

* 選其中一台安裝ipfs-swarm-key-gen即可

```sh
# 下載及安裝
go get -u github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen

# 產生swarm.key
ipfs-swarm-key-gen > ~/.ipfs/swarm.key

# 複製swarm.key到另外兩個節點
scp ~/.ipfs/swarm.key judy@192.168.101.17:/home/judy/.ipfs
scp ~/.ipfs/swarm.key tim@192.168.101.35:/home/tim/.ipfs
```

### 刪除bootstrap設定

* ipfs預設會自動連接到主網上的節點，故三台都需要將預設bootstrap刪除

* Command-line版刪除指令如下
    ```sh
    ipfs bootstrap rm --all
    ```

* 桌面版進到設置/ipfs設置，手動將bootstrap後的參數改為null，刪除後`重新啟動`(格式可參考Command-line版的`~/.ipfs/config`設定)

### 使三台ipfs互連

* 讓另外兩台都連到產生key的節點

* 確定三台都已經啟動ipfs daemon

* Command-line版輸入指令如下
    ```sh
    # ipfs bootstrap add /ip4/<安裝ipfs-swarm-key-gen的電腦ip>/tcp/4001/ipfs/<安裝ipfs-swarm-key-gen的ipfs id>
    ipfs bootstrap add /ip4/192.168.101.18/tcp/4001/ipfs/QmeH6vJ6xguwCqaBxoQ42tN77Q1FSVpkWpZ7x1XmdesuMj
    ```

* 桌面版進到設置/ipfs設置，手動將bootstrap後的參數由null改為`/ip4/192.168.101.18/tcp/4001/ipfs/QmeH6vJ6xguwCqaBxoQ42tN77Q1FSVpkWpZ7x1XmdesuMj`，刪除後`重新啟動`(格式可參考Command-line版的`~/.ipfs/config`設定)

### 檢查節點連接狀態

* 三台分別檢查是否有互相連接，如果沒連到會是空的

* Command-line版輸入指令如下
    ```sh
    ipfs swarm peers
    ```

* 桌面版則是查看用戶群
------------------

## 於ipfs私有網路進行操作測試

1. 再增加一台desktop

2. 

------------------
待看

ipfs config 指令 對block的處理
ipfs api
------------------

之後待補
1. 上述節點改用abcd並對應ip
2. 增加圖片
