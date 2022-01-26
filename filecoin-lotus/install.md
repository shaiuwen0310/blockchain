# Filecoin Lotus 安裝說明

## 介紹

根據[lotus官方操作手冊](https://docs.lotu.sh/)安裝lotus，Lotus為官方Filecoin之實現。

## 測試環境

    設備編號 1090401

* 顯卡 GeForce GTX 1050 Ti (`官方使用2080規格`)
* 處理器 Intel® Core™ i7-9700F
* 記憶體 64GB (`不符官方128GB規定`)
* 作業系統 Ubuntu 18.04.4 LTS

1. 根據官方說明，無法保證lotus測試網的硬體規格適用於MainNet
2. 於lotus測試網，使用AMD CPU好於Intel CPU

## 安裝步驟

1. 照順序執行
2. 以上述測試環境為準，不同環境須改成相對應的指令

### 安裝nvidia driver

`與BTC挖礦的算力目的不同，使用GPU是為了保證能在規定時間內完成時空證明`

```sh
sudo apt update
sudo apt upgrade

ubuntu-drivers devices

sudo apt install nvidia-driver-440 
sudo apt install nvidia-settings

sudo reboot

nvidia-smi
```

### 更新pip

```sh
sudo apt install python3-pip

pip3 install --upgrade pip
python -m pip install --upgrade pip3
python -m pip3 install --upgrade pip3
python3 -m pip3 install --upgrade pip3
python3 -m pip install --upgrade pip3
python3 -m pip install --upgrade pip

pip3 list
```

### 安裝cuda

1. CUDA由Nvidia開發，用在自己的GPU上進行通用計算
2. 配合GPU規格，使用cuda 10，不可使用11

下載[CUDA Toolkit 10.0 Archive](https://developer.nvidia.com/cuda-10.0-download-archive?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=1804&target_type=runfilelocal)

Notes: 下載要比較久

```sh
# 剛開始問要不要裝nvidia，記得不要安裝
sudo ./cuda_10.0.130_410.48_linux.run
```

### 設定cuda環境變數

```sh
vim ~/.bashrc
```

添加以下環境變數:

```sh
# CUDA VARIABLES
export PATH=/usr/local/cuda/bin:$PATH
export CUDA_HOME=/usr/local/cuda
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs:$LD_LIBRARY_PATH
# END CUDA VARIABLES
```

```sh
source ~/.bashrc
```

### 安裝cuddn

加速用

1. 若有下載cuddn則安裝(需登入官方網站)
2. 檔名cudnn-10.0-linux-x64-v7.6.5.32.tgz
3. 將`lib64/`、`include/`中的檔案分別放入`/usr/local/cuda/`相對應的資料夾中


### 安裝Python的 Tensorflow library

1. 配合GPU規格，需使用2.0的版本

```sh
# 用來看有哪些版本
pip3 install tensorflow==3.3.0000

pip3 install tensorflow-gpu==2.0.0
```

建立測試範例tf_GPU_test.py，增加以下內容:

```py
import tensorflow as tf
a = tf.constant([1.0 ,2.0 ,3.0 ,4.0 ,5.0 ,6.0] ,shape=(2 ,3) ,name='a')
b = tf.constant([1.0 ,2.0 ,3.0 ,4.0 ,5.0 ,6.0] ,shape=(3 ,2) ,name='b')
c = tf.matmul(a ,b)
print(c)
```

測看看 tensorflow是否有用到gpu:

```sh
python3 tf_GPU_test.py
```

### 安裝Lotus' dependencies

```sh
sudo apt update
sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl
sudo apt upgrade

# 選擇1
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

```sh
# 將複製~/.cargo/env內容到~/.bashrc
vim ~/.bashrc
```

添加以下環境變數:

```sh
# RUST VARIABLES
export PATH="$HOME/.cargo/bin:$PATH"
# END RUST VARIABLES
```

```sh
source ~/.bashrc

rustc --version
```

### 安裝go

1. 安裝go 1.14以上的版本
2. 使用到[GO官網](https://golang.org/dl/)下載binary的安裝方式

```sh
tar -xvzf go1.14.4.linux-amd64.tar.gz >/dev/null 2>&1

sudo mv go /usr/local
```

```sh
vim ~/.bashrc
```

添加以下環境變數:

```sh
# GO VARIABLES
export GOROOT=/usr/local/go
export GOPATH=~/go
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin
# END GO VARIABLES
```

```sh
source ~/.bashrc

go version
```

### 調整ulimit上限

ubuntu預設不可做ulimit -n 10000的動作，需調整上限

1. __`不確定是哪個調整使ulimit更改成功`__
2. __`即使調整成功，需要ulimit調整的情況下，還是要先手動su <user>，ulimit才會變成調整後的`__

```sh
sudo vim /etc/pam.d/common-session
```

添加以下內容:

```sh
session required pam_limits.so
```

```sh
sudo vim /etc/security/limits.conf
```

添加以下內容:

```sh
* soft     nproc          65535
* hard     nproc          65535
* soft     nofile         102400
* hard     nofile         102400
```

```sh
sudo vim /etc/sysctl.conf
```

添加以下內容:

```sh
fs.file-max = 65535
```

```sh
/sbin/sysctl -p
```

```sh
sudo vim /etc/profile
```

添加以下內容:

```sh
ulimit -SHn 65535
```

```sh
sudo reboot
```

__`若要在ulimit調整後的情況下執行程式，要先su lotus，ulimit -n才會改變`__

### 安裝Lotus

```sh
git clone https://github.com/filecoin-project/lotus.git
cd lotus/

make clean && make all
sudo make install
```
