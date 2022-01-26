#!/bin/bash
#

cd ${app_root_path}/fabric-network/network
# SOURCE="${BASH_SOURCE[0]}"
# # While $SOURCE is a symlink, resolve it
# while [ -h "$SOURCE" ]; do
#     DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
#     SOURCE="$( readlink "$SOURCE" )"
#     # If $SOURCE was a relative symlink (so no "/" as prefix, need to resolve it relative to the symlink base directory
#     [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
# done
# DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
# echo "$DIR"
# cd $DIR

export BYFN_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/ca && ls *_sk)

docker-compose -f docker-compose-cli.yaml -f docker-compose-ca.yaml -f docker-compose-etcdraft2.yaml -f docker-compose-couch.yaml up -d
