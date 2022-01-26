#!/bin/bash
#

export $(cat .env)

# 在這裡寫死要連到區塊鏈網路的參數
channelname=$(tail -n 1 ./genlist)

orderername=orderer
orderer2name=orderer2
orderer3name=orderer3
orderer4name=orderer4
orderer5name=orderer5

peername=peer0.org1
peer2name=peer1.org1
peer3name=peer2.org1

caname=ca_Org1

caOrg1Key=`basename ./../fabric-network/network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*`

cp -r ./../fabric-network/network/crypto-config/ ./gateway/

peer3IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${peer3name}.example.com)
if [ "${?}" != "0" ]; then
  # peer2 doesn't exsit
  echo
  echo "using networkConnection-template.yaml"
  cp ./gateway/networkConnection-template.yaml ./gateway/networkConnection.yaml
else
  echo
  echo "using networkConnection-addedpeer-template.yaml"
  cp ./gateway/networkConnection-addedpeer-template.yaml ./gateway/networkConnection.yaml
fi

ordererIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${orderername}.example.com)
orderer2IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${orderer2name}.example.com)
orderer3IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${orderer3name}.example.com)
orderer4IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${orderer4name}.example.com)
orderer5IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${orderer5name}.example.com)

peerIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${peername}.example.com)
peer2IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${peer2name}.example.com)
peer3IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${peer3name}.example.com)

caIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${caname})

sed -i "s/CHANNEL_NAME/${channelname}/g" ./gateway/networkConnection.yaml

sed -i "s/ORDERER_NAME/${orderername}.example.com/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER2_NAME/${orderer2name}.example.com/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER3_NAME/${orderer3name}.example.com/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER4_NAME/${orderer4name}.example.com/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER5_NAME/${orderer5name}.example.com/g" ./gateway/networkConnection.yaml

sed -i "s/PEER_NAME/${peername}.example.com/g" ./gateway/networkConnection.yaml
sed -i "s/PEER2_NAME/${peer2name}.example.com/g" ./gateway/networkConnection.yaml
sed -i "s/PEER3_NAME/${peer3name}.example.com/g" ./gateway/networkConnection.yaml

sed -i "s/ORDERER_IP/${ordererIP}/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER2_IP/${orderer2IP}/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER3_IP/${orderer3IP}/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER4_IP/${orderer4IP}/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER5_IP/${orderer5IP}/g" ./gateway/networkConnection.yaml

sed -i "s/PEER_IP/${peerIP}/g" ./gateway/networkConnection.yaml
sed -i "s/PEER2_IP/${peer2IP}/g" ./gateway/networkConnection.yaml
sed -i "s/PEER3_IP/${peer3IP}/g" ./gateway/networkConnection.yaml

sed -i "s/CA_IP/${caIP}/g" ./gateway/networkConnection.yaml
sed -i "s/CA_ORG1_KEY/${caOrg1Key}/g" ./gateway/networkConnection.yaml
sed -i "s/CA_ACCOUNT/${CA_ACCOUNT}/g" ./gateway/networkConnection.yaml
sed -i "s/CA_PWD/${CA_PWD}/g" ./gateway/networkConnection.yaml

res=$?
if [ $res -eq 0 ]; then
  docker-compose -f docker-compose.yaml up -d
fi
