#!/bin/bash

# docker version
fabric_version=2.2
fabric_ca_version=1.5
node_version_8=8.16
node_version_16=16.13
nginx_version=latest

# 
fabric_tag=2.2.4
fabric_bin_tar="hyperledger-fabric-linux-amd64-${fabric_tag}.tar.gz"
fabric_src_code="fabric-${fabric_tag}"
# 專案名稱
fabric_project="fabric-project"
images_folder="images-amd64"
default_domain="example.com"

function insFabric() {

   # 建立區塊鏈路徑
   mkdir -p ~/go/src/github.com/hyperledger
   echo "建立區塊鏈路徑 回應代碼: ${?}"

   # 安裝binary
   tar -C /tmp -xvf ./${fabric_bin_tar}
   sudo cp /tmp/bin/* /usr/local/bin
   echo "安裝binary 回應代碼: ${?}"

   # 放置fabric原始碼(不過不會用到)
   tar -C ~/go/src/github.com/hyperledger -zxf ./${fabric_src_code}.tar.gz
   echo "放置fabric原始碼 回應代碼: ${?}"
   mv ~/go/src/github.com/hyperledger/${fabric_src_code} ~/go/src/github.com/hyperledger/fabric

   # 放置專案
   tar -C ~/go/src/github.com/hyperledger -zxf ./${fabric_project}.tar.gz
   echo "放置${fabric_project}專案 回應代碼: ${?}"

   # 在本地匯入docker images
   importImages

   # ${fabric_project}/restart.sh這支預設是在rc.local執行，無法使用${USER}參數
   # 故在此更變user名稱
   sed -i "s/USERNAME/${USER}/g" ~/go/src/github.com/hyperledger/${fabric_project}/restart.sh
   echo "填寫restart.sh中的user名稱 回應代碼: ${?}"

   # 調整${fabric_project}中所有shell有執行權限
   find ~/go/src/github.com/hyperledger/${fabric_project} -type f -name "*.sh" -exec chmod +x {} \;
   echo "調整專案中所有shell為可執行權限 回應代碼: ${?}"

   # 更改domain name，會做詢問，若不更改則使用預設名稱
   askDomain
}

function preCheck(){

   go_ver=$(go version)
   go_rtn=$?
   docker_ver=$(docker --version)
   # 用ps 才可以確認是否已經重開機過
   docker_ps=$(docker ps -a)
   docker_rtn=$?
   compose_ver=$(docker-compose --version)
   compose_rtn=$?

   if [ ${go_rtn} -ne 0 -o ${docker_rtn} -ne 0 -o ${compose_rtn} -ne 0 ]; then
      echo "環境未安裝好，請先安裝好環境、重開機完成，再重新執行${0}..."
      echo "${go_ver}"
      echo "${docker_ver}"
      echo "${compose_ver}"
      # 由於環境沒安裝好，因此直接結束執行
      exit 0
   else
      echo "環境皆安裝好，往下執行..."
      echo "${go_ver}"
      echo "${docker_ver}"
      echo "${compose_ver}"
   fi


   if [ -d "/home/${USER}/go/src" ]; then
      # 有go的workspace，往下執行...
      echo
   else
      echo "/home/${USER}/go/src 路徑不存在，請先建立好go的workspace再重新執行..."
      exit 0
   fi


   # 檢核是否有${fabric_project}/ 有則不執行
   if [ -d "/home/${USER}/go/src/github.com/hyperledger/${fabric_project}" ]; then
      echo "${fabric_project}/ 已存在，請確認是否已執行過${0}"
      exit 0
   else
      echo
   fi
}

function askDomain() {
   echo
   read -p "需要自行設定網域名稱嗎？亦可用預設名稱(${default_domain})。 [Y/N] " ans
   case "$ans" in
   y | Y)
      echo "自行設定網域名稱..." 
      changeDomain
      ;;
   n | N)
      echo "使用預設網域名稱..."
      ;;
   *)
      echo "不合法回覆..."
      askDomain
      ;;
   esac
}

function changeDomain() {
   cd ~/go/src/github.com/hyperledger/${fabric_project}

   echo
   read -p "請輸入網域名稱(eg. ezchain.net)：" domain

   grep "${default_domain}" -rl *|xargs sed -i "s/${default_domain}/${domain}/g"
   echo "調整網域名稱 回應代碼: ${?}"
}

function importImages() {
   echo "====== 開始匯入docker images ======"
   echo
   starttime=$(date +%s)

   echo "匯入hyperledger/fabric-baseos:${fabric_version}..."
   docker load --input ./${images_folder}/fabric-baseos-${fabric_version}.tar
   echo "rtnc: ${?}"
   echo 

   echo "匯入hyperledger/fabric-ca:${fabric_ca_version}..."
   docker load --input ./${images_folder}/fabric-ca-${fabric_ca_version}.tar
   echo "rtnc: ${?}"
   echo

   echo "匯入hyperledger/fabric-ccenv:${fabric_version}..."
   docker load --input ./${images_folder}/fabric-ccenv-${fabric_version}.tar
   echo "rtnc: ${?}"
   echo

   echo "匯入hyperledger/fabric-orderer:${fabric_version}..."
   docker load --input ./${images_folder}/fabric-orderer-${fabric_version}.tar
   echo "rtnc: ${?}"
   echo

   echo "匯入hyperledger/fabric-peer:${fabric_version}..."
   docker load --input ./${images_folder}/fabric-peer-${fabric_version}.tar
   echo "rtnc: ${?}"
   echo

   echo "匯入hyperledger/fabric-tools:${fabric_version}..."
   docker load --input ./${images_folder}/fabric-tools-${fabric_version}.tar
   echo "rtnc: ${?}"
   echo

   echo "匯入node:${node_version_8}..."
   docker load --input ./${images_folder}/node-${node_version_8}.tar
   echo "rtnc: ${?}"
   echo

   echo "匯入node:${node_version_16}..."
   docker load --input ./${images_folder}/node-${node_version_16}.tar
   echo "rtnc: ${?}"
   echo

   echo "匯入nginx:${nginx_version}..."
   docker load --input ./${images_folder}/nginx-${nginx_version}.tar
   echo "rtnc: ${?}"
   echo

   echo "Total execution time: $(($(date +%s)-starttime)) secs"
   echo "====== 結束匯出docker images ======"
}


preCheck
insFabric

