#!/bin/sh

export app_root_path="/home/USERNAME/go/src/github.com/hyperledger/fabric-project"

sh ${app_root_path}/fabric-network/network/restart.sh

sh ${app_root_path}/node-api-service/restartApp.sh

sh ${app_root_path}/webui/restartApp.sh

