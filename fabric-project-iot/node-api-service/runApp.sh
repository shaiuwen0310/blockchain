#!/bin/bash
#

export $(cat .env)

#
# 複製一份gateway設定檔
cp ./gateway/iotNet-tmplt.yaml ./gateway/iotNet.yaml

# 
# 在所複製的gateway設定檔上，依照yaml格式增加帳本label的設定
END0=$(cat genlist | wc -l | cut -d" " -f 1)
YAML_STR=""
for num in $(seq 1 $END0);
do
  # 組好要放上yaml檔的channel格式(\  是空兩格，\n是段行)
  str="\  CHANNEL$(($num-1))_NAME: \n\    << : *channel\n"
  YAML_STR=${YAML_STR}${str}
done
# 將組好的內容放到yaml檔上(sed a表示在下一行插入內容)
sed -i "/channels:/ a ${YAML_STR}" ./gateway/iotNet.yaml

#
# 替換設定檔中，所有帳本的名稱
FILENAME=genlist
i=1
for channelname in `cat $FILENAME`;
do
  # 替換帳本名稱
  find ./gateway/ ! -name "*-tmplt.yaml" -type f | xargs sed -i 's/'CHANNEL$(($i-1))_NAME'/'${channelname}'/g'
  i=$(($i+1))
done

# 
# 替換設定檔中，所有orderer的label
END1=$(docker ps -a | grep "fabric-orderer" | wc -l | cut -d" " -f 1)
for j in $(seq 1 $END1);
do
  if [ "${j}" = "1" ]; then
    orderername=orderer
    nameLabel=ORDERER_NAME
    ipLabel=ORDERER_IP
  else
    # orderer容器名稱
    orderername=orderer${j}
    # 設定檔中orderer的替換label名稱
    nameLabel=ORDERER${j}_NAME
    ipLabel=ORDERER${j}_IP
  fi
  # 換名字
  find ./gateway/ ! -name "*-tmplt.yaml" -type f | xargs sed -i 's/'${nameLabel}'/'${orderername}'.example.com/g'
  # 換IP
  ordererIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${orderername}.example.com)
  find ./gateway/ ! -name "*-tmplt.yaml" -type f | xargs sed -i 's/'${ipLabel}'/'${ordererIP}'/g'
done

# 
# 替換設定檔中，所有peer的label
END2=$(docker ps -a | grep "fabric-peer" | wc -l | cut -d" " -f 1)
for k in $(seq 1 $END2);
do
  # peer容器名稱
  peername=peer$((${k}-1)).org1
  # peer容器IP
  peerIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${peername}.example.com)
  # 設定檔中peer的替換label名稱
  nameLabel=PEER$((${k}-1))_NAME
  ipLabel=PEER$((${k}-1))_IP
  # 換名字
  find ./gateway/ ! -name "*-tmplt.yaml" -type f | xargs sed -i 's/'${nameLabel}'/'${peername}'.example.com/g'
  # 換IP
  find ./gateway/ ! -name "*-tmplt.yaml" -type f | xargs sed -i 's/'${ipLabel}'/'${peerIP}'/g'
done

#
# CA變數替換( 目前只有一個ca，故寫死參數 )
caname=ca_Org1
caOrg1Key=`basename ./../fabric-network/network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*`
caIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${caname})
# 替換CA的變數
find ./gateway/ ! -name "*-tmplt.yaml" -type f | xargs sed -i -e 's/CA_IP/'${caIP}'/g' -e 's/CA_ORG1_KEY/'${caOrg1Key}'/g' -e 's/CA_ACCOUNT/'${CA_ACCOUNT}'/g' -e 's/CA_PWD/'${CA_PWD}'/g'

# 
# ./gateway/會被包在容器中，設定檔中使用此複製的crypto-config/的路徑
cp -r ./../fabric-network/network/crypto-config/ ./gateway/


function startAPI() {

  if [ -f "docker-compose.yaml" ]; then
    echo "啟動api服務..."
    docker-compose -f docker-compose.yaml up -d
    sleep 10
  else
    echo "未啟動api服務..."
  fi
}

startAPI