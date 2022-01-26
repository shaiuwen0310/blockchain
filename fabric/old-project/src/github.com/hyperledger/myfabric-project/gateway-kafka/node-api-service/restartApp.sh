#!/bin/bash
#

cd /home/judy/go/src/github.com/hyperledger/myfabric-project/iotGW/node-api-service

# 在這裡寫死要連到區塊鏈網路的參數
channelname=mychannel
orderername=orderer0
peername=peer0.org1
caname=ca-org1

while getopts "c:o:p:" opt;
do
  case "${opt}" in
  c)
    channelname=${OPTARG}
    ;;
  o)
    orderername=${OPTARG}.example.com
    ;;
  p)
    peername=${OPTARG}.example.com
    ;;
  esac
done

cp ./gateway/networkConnection-template.yaml ./gateway/networkConnection.yaml

ordererIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${orderername}.example.com)
peerIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${peername}.example.com)
caIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${caname})

sed -i "s/CHANNEL_NAME/${channelname}/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER_NAME/${orderername}.example.com/g" ./gateway/networkConnection.yaml
sed -i "s/PEER_NAME/${peername}.example.com/g" ./gateway/networkConnection.yaml
sed -i "s/ORDERER_IP/${ordererIP}/g" ./gateway/networkConnection.yaml
sed -i "s/PEER_IP/${peerIP}/g" ./gateway/networkConnection.yaml
sed -i "s/CA_IP/${caIP}/g" ./gateway/networkConnection.yaml

res=$?
if [ $res -eq 0 ]; then
  docker-compose -f docker-api.yaml up -d
fi

res=$?
echo "${res}"