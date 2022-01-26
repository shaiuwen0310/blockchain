# Filecoin Lotus 操作說明

## 介紹

根據[lotus官方操作手冊](https://docs.lotu.sh/)安裝lotus，Lotus為官方Filecoin之實現。

### Lotus 分別有三個執行檔
1. lotus 分散存儲網絡客戶端
2. lotus-seal-worker 遠程存儲礦工
    * 要放在其他電腦上，該電腦要複製參數證明的資料，要連到lotus-storage-miner的電腦上
    * 幫助storage miner更快完成seal
    * seal: 封裝資料的過程，返回對存儲在seactor中的數據的承諾和證明
3. lotus-storage-miner 分散式存儲網絡存儲礦工



## 測試步驟

### 加入測試鏈 (Join Testnet)

__`同步區塊，花費一天左右的時間`__

terminal 1

```sh
# 登入當前使用者
su lotus

# 查看是否大於10000
ulimit -n

# 啟動 分散存儲網絡 客戶端
lotus daemon
```

terminal 2

```sh
# 查看連結的peer數量
lotus net peers | wc -l

# 登入當前使用者
su lotus

# 查看是否大於10000
ulimit -n

# 同步區塊
lotus sync wait
```
__`同步完成前不要關掉上述兩個分頁`__

### 設定硬體名稱到環境變數

非官方實驗使用的GPU，需增加此步驟

```sh
# 查看gpu名稱，並上網查到GeForce GTX 1050 Ti with 768 cores
nvidia-smi -q

sudo vim ~/.bashrc
```

添加以下環境變數:
```sh
# Filecoin Lotus VARIABLES
BELLMAN_CUSTOM_GPU="GeForce GTX 1050 Ti:768"
# END Filecoin Lotus VARIABLES
```

```sh
source ~/.bashrc
```

### 儲存採礦 (Storage Mining)

要先lotus持續開著，且已sync data，才可往下進行

```sh
# 使用bls簽章建立帳號，乙太坊也使用bls簽章
lotus wallet new bls

lotus wallet list
```

進入[faucet](https://faucet.testnet.filecoin.io/)，點選Create Miner，輸入剛剛列出的bls帳號，畫面跳轉前不可關閉，複製最後一行到終端機執行，如下：

```sh
# 此為新的存儲礦工addr，花費一天左右的時間
lotus-storage-miner init --actor=t0120310 --owner=t3sszexn7am27df5nn2rudasxrrbmvfhysazjb646ifoa5rd6fahc474jywf2os6emqearetk3hpirtdtya7oa
```

[lotus-storage-miner 指令說明](#lotus-storage-miner)

```sh
vim ~/.bashrc
```

添加以下環境變數:

```sh
# FILECOIN LOTUS VARIABLE 加快挖礦效能
FIL_PROOFS_MAXIMIZE_CACHING=1
FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
# END FILECOIN LOTUS VARIABLE
```

```sh
source ~/.bashrc
```

```sh
lotus-storage-miner run

lotus-storage-miner info

lotus-storage-miner sectors pledge
```

在2TB硬碟 新增資料夾：
```
/media/lotus/647e5905-613f-4b53-9290-3e678f36b91b/lotus/persisten_storage
/media/lotus/647e5905-613f-4b53-9290-3e678f36b91b/lotus/fast_cache/
```

```sh
# 設置數據存儲路徑，該路徑用來存儲最終密封好的數據
# 執行該命令可能需要一點時間等待
lotus-storage-miner storage attach --store --init /media/lotus/647e5905-613f-4b53-9290-3e678f36b91b/lotus/persisten_storage

# 設置密封扇區的存儲路徑，密封完成之後該路徑下的數據會被自動清空，相當於臨時目錄
# 執行該命令可能需要一點時間等待
lotus-storage-miner storage attach --seal --init /media/lotus/647e5905-613f-4b53-9290-3e678f36b91b/lotus/fast_cache/
```

__`目前的問題為，實體記憶體不足、cpu和GPU沒被使用`__
__`跳過Storage Mining`__

### 在Lotus Testnet上儲存資料 (Storing Data)

```sh
vim Lotus.txt

# 在本地添加文件使您可以在Lotus Testnet上進行礦工交易
lotus client import Lotus.txt
```

返回：

```sh
# 檔案的CID
bafkreidy4jwnwfosaev6he66oi3wcnujyv3vcnxchffyff2dh7uv764qt4
```

```sh
# 列出本地文件
lotus client local
```

返回：

```sh
# CID, name, size in bytes, and status
bafkreidy4jwnwfosaev6he66oi3wcnujyv3vcnxchffyff2dh7uv764qt4 Desktop/Lotus.txt 17 B ok
```

```sh
# 列出所有可以儲存資料的miner
lotus state list-miners

lotus state list-miners | grep t0120310

# 挑一個miner，我挑自己
lotus client query-ask t0120310
```

返回：

```sh
Ask: t0120310
Price per GiB: 0.0000000005
Max Piece size: 32 GiB
```

```sh
# Store a Data CID with a miner
lotus client deal bafkreidy4jwnwfosaev6he66oi3wcnujyv3vcnxchffyff2dh7uv764qt4 t0120310 1 12
```

返回：

```sh
bafyreiauondbgbufrugsuzbqk47ohtsybvg2f7e5amvbql2cza2ulk6efu
```

























-------------------------------

## 指令說明

### lotus-storage-miner

```sh
lotus-storage-miner init ...
```

1. 會下載data到 /var/tmp/filecoin-proof-parameters，約一個工作天的時數
2. 這些資料用來儲存數據、儲存證明(storage miner證明自己有儲存檔案的證明方式，如時空證明)的時候會使用

備註：有18個檔案

-------------------------------

## 名詞解釋

### Sector

磁盤上的每個磁軌被等分為若干個弧段，這些弧段便是硬碟的磁區（Sector）。硬碟的第一個磁區，叫做開機磁區

參考[硬碟物理結構](https://zh.wikipedia.org/zh-tw/%E7%A1%AC%E7%9B%98#%E7%89%A9%E7%90%86%E7%BB%93%E6%9E%84)