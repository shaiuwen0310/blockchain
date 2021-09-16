# fabric-project

## **說明**

1. 這是一個fabric應用，此專案包含：一個fabric網路、一個iot應用
2. 分成三步驟：環境安裝、安裝fabric、安裝本應用
3. `先放上來，以下說明尚未調整好`

---

## **環境安裝**

* apt-get
    ```sh
    sudo apt-get install curl jq git
    ```

* Go
    ```sh
    gozip="go1.12.14.linux-amd64.tar.gz"
    curl -O https://storage.googleapis.com/golang/${gozip}
    sudo tar -C /usr/local -xzf ./${gozip}
    
    file="/home/${USER}/.bashrc"
    echo "" >> ${file}
    echo "#GO VARIABLES" >> ${file}
    echo "export GOROOT=/usr/local/go" >> ${file}
    echo "export GOPATH=~/go" >> ${file}
    echo 'export PATH=$PATH:$GOROOT/bin' >> ${file}
    echo 'export PATH=$PATH:$GOPATH/bin' >> ${file}
    echo "#END GO VARIABLES" >> ${file}
    source ~/.bashrc
    go version

    mkdir ~/go && mkdir -p ~/go/src ~/go/pkg ~/go/bin
    ```

* docker
    ```sh
    curl -sSL https://get.docker.com/ | sh
    sudo usermod -aG docker ${USER}
    ```

* docker-compose
    ```sh
    sudo curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
    ```

* 以上安裝完後，**請重新啟動設備**，使docker可正常使用

--- 

## **建置fabric1.4.8**
**`make sure docker can be used: docker ps -a`**
```sh
mkdir -p ~/go/src/github.com/hyperledger
cd ~/go/src/github.com/hyperledger

# fabric1.4.8 fabric-ca1.4.8 fabric-baseimage0.4.21
curl -sSL http://bit.ly/2ysbOFE | bash -s -- 1.4.8 1.4.8 0.4.21
sudo cp ~/go/src/github.com/hyperledger/fabric-samples/bin/* /usr/local/bin/
ls /usr/local/bin/

# git clone https://github.com/hyperledger/fabric.git
# cd ~/go/src/github.com/hyperledger/fabric
# git checkout v1.4.8
# git branch
# make docker-thirdparty
```

---

## **安裝本專案**

* 下載
    ```sh
    cd ~/go/src/github.com/hyperledger
    git clone XXX
    ```

* 調整shell執行權限
    * 確保執行shell時，include的shell都可被成功呼叫
    ```sh
    cd ~/go/src/github.com/hyperledger/iot-1u

    # 調整iot-1u中所有shell有執行權限
    find ~/go/src/github.com/hyperledger/iot-1u -type f -name "*.sh" -exec chmod +x {} \;
    ```

* 調整自動重起區塊鏈的shell
    * restart.sh預設是提供給rc.local執行
    * 若`無需`開機自動重起功能，則`無需`執行
    * **`更新gitlab前，必需還原restart.sh`**
    ```sh
    cd ~/go/src/github.com/hyperledger/iot-1u

    # fabric-project在fabric-pkg中是固定名稱，放在gitlab改成手動調整
    sed -i "s/fabric-project/iot-1u/g" ~/go/src/github.com/hyperledger/iot-1u/restart.sh

    # iot-1u/restart.sh這支預設是在rc.local執行，無法使用${USER}參數，故在此更變user名稱
    sed -i "s/USERNAME/${USER}/g" ~/go/src/github.com/hyperledger/iot-1u/restart.sh
    ```