#!/bin/bash

# 會做檢核，所以可重複執行

gozip="go1.15.1.linux-amd64.tar.gz"

function insCmd() {
  sudo apt-get install curl jq git vim
}

function insGo() {

   # 檢核是否以安裝go
   go_ver=$(go version | cut -d' ' -f 3)
   if [ -z "${go_ver}" ]; then
      echo "尚未安裝go，開始安裝${gozip}..."
   else
      echo "已安裝 $(go version)"
      return
   fi

   # 安裝
   sudo tar -C /usr/local -xzf ./${gozip}

   # 設定環境變數
   file="/home/${USER}/.bashrc"
   bp="/home/${USER}/.bashrc_bp"
   cp ${file} ${bp}

   echo "" >> ${file}
   echo "# GO VARIABLES" >> ${file}
   echo "export GOROOT=/usr/local/go" >> ${file}
   echo "export GOPATH=~/go" >> ${file}
   echo 'export PATH=$PATH:$GOROOT/bin' >> ${file}
   echo 'export PATH=$PATH:$GOPATH/bin' >> ${file}
   echo "# END GO VARIABLES" >> ${file}

   source ${file}
   sleep 3

   # 建立go的workspace
   mkdir ~/go && mkdir -p ~/go/src ~/go/pkg ~/go/bin
}

function insDocker() {

   # 檢核是否以安裝docker
   docker_ver=$(docker --version | cut -d' ' -f 3)
   if [ -z "${docker_ver}" ]; then
      echo "尚未安裝docker，開始安裝..."
   else
      echo "已安裝 $(docker --version)"
      return
   fi

   # 安裝
   curl -sSL https://get.docker.com/ | sh

   # 設定一般user帳號也可使用docker
   sudo usermod -aG docker ${USER}
   echo
}

function insDockerCompose(){

   compose_ver=$(docker-compose --version | cut -d' ' -f 3)
   if [ -z "${compose_ver}" ]; then
      echo "尚未安裝docker compose，開始安裝..."
   else
      echo "已安裝 $(docker-compose --version)"
      return
   fi

   # 安裝
   sudo curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
}

function check(){
   jq_ver=$(jq --version)
   jq_rtn=${?}
   curl_ver=$(curl -V)
   curl_rtn=${?}

   if [ ${jq_rtn} -ne 0 -o ${curl_rtn} -ne 0 ]; then
      echo "jq或curl未安裝好，請先確認問題，再重新執行${0}..."
      echo "${jq_ver}"
      echo "${curl_ver}"
      # 由於環境沒安裝好，因此直接結束執行
      exit 0
   else
      echo "${jq_ver}"
      echo "${curl_ver}"
   fi

}

insCmd
# 沒裝好cmd就不能往下跑
check

insGo
insDocker
insDockerCompose

echo
echo "安裝完成後請重新啟動機器，使docker的設定生效!"
