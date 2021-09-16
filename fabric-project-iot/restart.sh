#!/bin/sh

# 自動安裝區塊鏈環境時，已經自動替換為當下使用者;若非透過自動安裝，請手動替換

export app_root_path="/home/USERNAME/go/src/github.com/hyperledger/fabric-project"

sh ${app_root_path}/fabric-network/network/restart.sh

sh ${app_root_path}/node-api-service/restartApp.sh

