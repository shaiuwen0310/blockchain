#!/bin/bash
#

rm ./gateway/networkConnection.yaml
rm -rf ./gateway/crypto-config

docker-compose -f docker-api.yaml down