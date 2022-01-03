# anchor過程
### 說明
- 使用fabric-samples/test-network查看anchor流程
- 會使用到configtxlator執行檔，所以要在cli中執行
### 組織一設置anchor的步驟：
- 獲取通道 mychannel 的通道配置(createAnchorPeerUpdate)

  - 獲取通道的最新配置塊

    - ```sh
      peer channel fetch config config_block.pb -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL --tls --cafile $ORDERER_CA
      ```

    - 產生檔案config_block.pb

  - 將config_block.pb解碼為 JSON

    - ```sh
      OUTPUT=Org1MSPconfig.json
      
      configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
      ```

    - 產生檔案Org1MSPconfig.json

  - 修改Org1MSPconfig.json以追加`anchor節點`資訊

    - ```sh
      jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' ${CORE_PEER_LOCALMSPID}config.json > ${CORE_PEER_LOCALMSPID}modified_config.json
      ```

    - 產生Org1MSPmodified_config.json

  - 比較Org1MSPconfig.json及Org1MSPmodified_config.json的差異

    - 將兩個檔案分別轉成.pb檔案

      - ```sh
        ORIGINAL=Org1MSPconfig.json
        
        configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
        ```

      - ```sh
        MODIFIED=Org1MSPmodified_config.json
        
        configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
        ```

      - 分別產生config_block.pb及modified_config.pb

    - 使用兩者的.pb檔案計算差異

      - 需要channel名稱

      - ```sh
        CHANNEL=mychannel
        
        configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb >config_update.pb
        ```

      - 產生config_update.pb

    - 將config_update.pb轉成json

      - ```sh
        configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
        ```

      - 產生config_update.json

    - 封裝config_update.json

      - 需要channel名稱

      - 需要config_update.json內容

      - ```sh
        CHANNEL=mychannel
        
        echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
        ```

      - 產生config_update_in_envelope.json

    - 將config_update_in_envelope.json轉成.pb檔案

      - ```sh
        OUTPUT=Org1MSPanchors.tx
        
        configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >"${OUTPUT}"
        ```

      - 產生Org1MSPanchors.tx

  - 此步驟(獲取通道 mychannel 的通道配置)，最終產生Org1MSPanchors.tx檔案

- 簽名並發送指定的通道configtx更新文件(updateAnchorPeer)

  - ```sh
    CHANNEL_NAME=mychannel
    
    peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA >&log.txt
    ```

  - 在peer0.org1中的log

    - ```
      2021-12-30 04:02:49.247 UTC [gossip.gossip] JoinChan -> INFO 02f Joining gossip network of channel mychannel with 2 organizations
      2021-12-30 04:02:49.247 UTC [gossip.gossip] learnAnchorPeers -> INFO 030 Learning about the configured anchor peers of Org1MSP for channel mychannel: [{peer0.org1.example.com 7051}]
      2021-12-30 04:02:49.247 UTC [gossip.gossip] learnAnchorPeers -> INFO 031 Anchor peer for channel mychannel with same endpoint, skipping connecting to myself
      2021-12-30 04:02:49.247 UTC [gossip.gossip] learnAnchorPeers -> INFO 032 No configured anchor peers of Org2MSP for channel mychannel to learn about
      2021-12-30 04:02:49.247 UTC [committer.txvalidator] Validate -> INFO 033 [mychannel] Validated block [1] in 4ms
      ```


