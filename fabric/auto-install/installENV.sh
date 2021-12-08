#!/bin/bash

# 會做檢核，所以可重複執行

# 當前所需go版本
required_go_ver="go1.17.3"
gozip="${required_go_ver}.linux-amd64.tar.gz"
# 當前所需docker版本
required_docker_ver="20.10.7"

function insCmd() {
  sudo apt-get install curl jq git vim
}

function insGo() {
   # 所需版本
   required_go_front=$(echo ${required_go_ver} | cut -d 'o' -f 2 | cut -d '.' -f 1)
   required_go_mid=$(echo ${required_go_ver} | cut -d 'o' -f 2 | cut -d '.' -f 2)

   # 當前安裝版本
   go_ver=$(go version | cut -d' ' -f 3)
   go_front=$(echo ${go_ver} | cut -d 'o' -f 2 | cut -d '.' -f 1)
   go_mid=$(echo ${go_ver} | cut -d 'o' -f 2 | cut -d '.' -f 2)

   if [ -z "${go_ver}" ]; then
      echo "尚未安裝go，開始安裝${gozip}..."

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
      if [ ! -d "/home/${USER}/go" ]; then
         echo "建立go資料夾..."
         mkdir ~/go && mkdir -p ~/go/src ~/go/pkg ~/go/bin
      else
         echo "go資料夾已存在：/home/${USER}/go"
      fi
   elif [ "${go_front}" -lt "${required_go_front}" ] || [ "${go_mid}" -lt "${required_go_mid}" ]; then
      echo "目前已安裝的版本為${go_ver}，請自行升級至${required_go_ver}..."
      exit 1
   else
      echo "已安裝 $(go version)"
      return
   fi
}

function insDocker() {

   # 所需版本
   required_docker_front=$(echo ${required_docker_ver} | cut -d ',' -f 1 | cut -d '.' -f 1)
   required_docker_mid=$(echo ${required_docker_ver} | cut -d ',' -f 1 | cut -d '.' -f 2)

   # 當前安裝版本
   docker_ver=$(docker --version | cut -d' ' -f 3)
   docker_front=$(docker -v | cut -d' ' -f 3 | cut -d',' -f 1 | cut -d'.' -f 1)
   docker_mid=$(docker -v | cut -d' ' -f 3 | cut -d',' -f 1 | cut -d'.' -f 2)

   if [ -z "${docker_ver}" ]; then
      echo "尚未安裝docker，開始安裝..."
      # 安裝
      curl -sSL https://get.docker.com/ | sh

      # 設定一般user帳號也可使用docker
      sudo usermod -aG docker ${USER}
      echo
   elif [ "${docker_front}" -lt "${required_docker_front}" ] || [ "${docker_mid}" -lt "${required_docker_mid}" ]; then
      echo "目前已安裝的版本為${docker_ver}，請自行升級至${required_docker_ver}..."
      exit 1
   else
      echo "已安裝 $(docker --version)"
      return
   fi


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
