# ca建立憑證過程
### 說明
- X.509認證指的是RFC5280里定義的X.509 v3
- 若client使用SDK，版本：^2.2.4
### 相關連結
- [如何使用 OpenSSL 簽發中介 CA](https://blog.davy.tw/posts/use-openssl-to-sign-intermediate-ca/)
- [如何使用 OpenSSL 建立開發測試用途的自簽憑證](https://blog.miniasp.com/post/2019/02/25/Creating-Self-signed-Certificate-using-OpenSSL)
- [AWS：Register and Enroll a Hyperledger Fabric Admin](https://docs.aws.amazon.com/managed-blockchain/latest/hyperledger-fabric-dev/managed-blockchain-hyperledger-create-admin.html)
- [Hyperledger Fabric(集成Fabric-ca)](https://blog.csdn.net/qq_29879799/article/details/104145357)：有文件上的架構圖，建立方式跟samples有點差異
- [Fabric-CA簡介](https://www.gushiciku.cn/pl/pFdf/zh-tw)：Fabric 設計中考慮了三種類型的證書
- 

### 名詞解釋
- register及enroll
  - You may **register** your name for entry into a particular college. If you are accepted, after your exams, then you are **enrolled**. **enrollment**意味著學生已被正式錄取並正在大學上課
  - fabric-ca-client：先向ca-server註冊帳號（register），再登入該帳號（enroll）去產生憑證
  - 現實中的流程：[憑證註冊中心（RA）是什麼](https://marketing.ares.com.tw/newsletter/2012-11/ra)
- Fabric CA中的**register**和**enroll**是什麼意思？
  - **register**由 CA 管理員完成。 **用戶名和密碼被分配給一個身份**，以及屬性（例如，身份是管理員還是節點？）。 此註冊將用戶名和密碼以及有關身份的其他相關信息放入 CA 的數據庫中。 此時尚未生成任何證書。 身份只是被註冊了。
  - **enroll**是創建證書並將其提供給身份用戶的過程。 用戶名和密碼是帶外提供給該用戶的，他們使用名稱和密碼作為對 CA 的fabric-ca-client 調用的一部分。 然後生成公鑰和私鑰。
  - **register**和**enroll**分開的原因是為了確保只有該身份用戶才能收到他們的私鑰。

### 看範例：使用ca-server建立憑證的流程
- 檢核fabric-ca-client與hyperledger/fabric-ca:latest版本是否一致：1.5.2

- 啟動fabric-ca容器

  - 會吃fabric-ca-server的設定檔（fabric-ca-server-config.yaml）

  - 不同組織有不同的設定檔，欄位屬性不同

  - docker-compose.yaml及fabric-ca-server-config.yaml都有帳密設定

  - 理論上docker-compose.yaml設定的帳密會覆蓋fabric-ca-server-config.yaml的

  - fabric-ca-server-config.yaml的路徑：/etc/hyperledger/fabric-ca-server（images內本身就有fabric-ca-server-config.yaml）

  - 啟動時，上述路徑會產生：

    ```sh
    .
    ├── ca-cert.pem
    ├── fabric-ca-server-config.yaml
    ├── fabric-ca-server.db
    ├── IssuerPublicKey
    ├── IssuerRevocationPublicKey
    ├── msp
    │   ├── cacerts
    │   ├── keystore
    │   │   ├── 24d4fe400f7b92ddf852262ae9b69bfc21067ae9711c03224d5379a50ea99027_sk
    │   │   ├── 6d9eb0bfcfce223eb6754039a562d3b27cf00998decd18424adb4b8d8c698001_sk
    │   │   ├── IssuerRevocationPrivateKey
    │   │   └── IssuerSecretKey
    │   ├── signcerts
    │   └── user
    └── tls-cert.pem # enroll及register時的帶參
    ```

  - 

- 執行registerEnroll.sh：建立組織1憑證

  - FABRIC_CA_CLIENT_HOME：儲存憑證的資料夾，建立在local端，沒有volume到ca-server容器

  - fabric-ca-client enroll

    - 登入ca用戶
    - 會在`FABRIC_CA_CLIENT_HOME`下產生`msp/`(儲存enrollment certificate)及`fabric-ca-client-config.yaml`
    - `msp/`建立在local端

    ```sh
    Enrolling the CA admin
    + fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/fabric-ca/org1/tls-cert.pem
    
    2021/12/22 14:49:21 [INFO] Created a default configuration file at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/fabric-ca-client-config.yaml
    2021/12/22 14:49:21 [INFO] TLS Enabled
    2021/12/22 14:49:21 [INFO] generating key: &{A:ecdsa S:256}
    2021/12/22 14:49:21 [INFO] encoded CSR
    2021/12/22 14:49:21 [INFO] Stored client certificate at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/msp/signcerts/cert.pem
    2021/12/22 14:49:21 [INFO] Stored root CA certificate at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/msp/cacerts/localhost-7054-ca-org1.pem
    2021/12/22 14:49:21 [INFO] Stored Issuer public key at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/msp/IssuerPublicKey
    2021/12/22 14:49:21 [INFO] Stored Issuer revocation public key at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/msp/IssuerRevocationPublicKey
    ```

  - 在msp底下建立config.yaml

    - **不知道用途**

    - 關鍵字類似cryptogen的設定檔

    - Certificate路徑正確

    - `config.yaml`建立在local端

      ```yaml
      NodeOUs:
        Enable: true
        ClientOUIdentifier:
          Certificate: cacerts/localhost-7054-ca-org1.pem
          OrganizationalUnitIdentifier: client
        PeerOUIdentifier:
          Certificate: cacerts/localhost-7054-ca-org1.pem
          OrganizationalUnitIdentifier: peer
        AdminOUIdentifier:
          Certificate: cacerts/localhost-7054-ca-org1.pem
          OrganizationalUnitIdentifier: admin
        OrdererOUIdentifier:
          Certificate: cacerts/localhost-7054-ca-org1.pem
          OrganizationalUnitIdentifier: orderer
      ```

  - fabric-ca-client register

    - 註冊時，使用`fabric-ca-client-config.yaml`
    - 註冊peer0 user1 org1admin
    - local端不會產生東西，但在fabric-ca-server.db有註冊的資訊

    ```sh
    Registering peer0
    + fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/fabric-ca/org1/tls-cert.pem
    
    2021/12/22 16:13:08 [INFO] Configuration file location: /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/fabric-ca-client-config.yaml
    2021/12/22 16:13:08 [INFO] TLS Enabled
    2021/12/22 16:13:08 [INFO] TLS Enabled
    Password: peer0pw
    
    
    Registering user
    + fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/fabric-ca/org1/tls-cert.pem
    
    2021/12/22 16:13:08 [INFO] Configuration file location: /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/fabric-ca-client-config.yaml
    2021/12/22 16:13:08 [INFO] TLS Enabled
    2021/12/22 16:13:08 [INFO] TLS Enabled
    Password: user1pw
    
    
    Registering the org admin
    + fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/fabric-ca/org1/tls-cert.pem
    
    2021/12/22 16:13:08 [INFO] Configuration file location: /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/fabric-ca-client-config.yaml
    2021/12/22 16:13:08 [INFO] TLS Enabled
    2021/12/22 16:13:08 [INFO] TLS Enabled
    Password: org1adminpw
    ```

  - 前三個步驟的log

    ![pic1.png](pic1.png)

  - fabric-ca-client enroll，建立peer msp/

    - 透過更換msp/資料夾路經，更換登入的節點

    - 這時候打的帳號密碼，會是上一步register peer0的帳密

    - FABRIC_CA_CLIENT_HOME下，產生peers/資料夾，會根據帶入的host名稱建立子資料夾peers/peer0.org1.example.com/msp/

    - 應是透過上一層msp/自簽peer0.org1.example.com

      ![pic2.png](pic2.png)

    - 複製上一層msp/的config.yaml給peer的msp/

      - ![pic3.png](pic3.png)

  - fabric-ca-client enroll，建立peer tls/

    - 如同建立peer msp/方式來建立 tls/
    - ![pic4.png](pic4.png)
    - 將tls/中的憑證私鑰複製一份出來
      - pem轉crt
      - ![pic5.png](pic5.png)
    - 再次將tls/中的憑證私鑰複製一份出來
      - ![pic6.png](pic6.png)

  - fabric-ca-client enroll，建立user msp/

    - ```
      + fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp --tls.certfiles /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/fabric-ca/org1/tls-cert.pem
      2021/12/27 14:12:11 [INFO] TLS Enabled
      2021/12/27 14:12:11 [INFO] generating key: &{A:ecdsa S:256}
      2021/12/27 14:12:11 [INFO] encoded CSR
      2021/12/27 14:12:11 [INFO] Stored client certificate at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/cert.pem
      2021/12/27 14:12:11 [INFO] Stored root CA certificate at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/cacerts/localhost-7054-ca-org1.pem
      2021/12/27 14:12:11 [INFO] Stored Issuer public key at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/IssuerPublicKey
      2021/12/27 14:12:11 [INFO] Stored Issuer revocation public key at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/IssuerRevocationPublicKey
      ```

    - ![pic7.png](pic7.png)

    - 複製config.yaml到user的msp/底下

  - fabric-ca-client enroll，建立組織admin msp/

    - ```
      + fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp --tls.certfiles /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/fabric-ca/org1/tls-cert.pem
      2021/12/27 14:26:04 [INFO] TLS Enabled
      2021/12/27 14:26:04 [INFO] generating key: &{A:ecdsa S:256}
      2021/12/27 14:26:04 [INFO] encoded CSR
      2021/12/27 14:26:04 [INFO] Stored client certificate at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/cert.pem
      2021/12/27 14:26:04 [INFO] Stored root CA certificate at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/cacerts/localhost-7054-ca-org1.pem
      2021/12/27 14:26:04 [INFO] Stored Issuer public key at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/IssuerPublicKey
      2021/12/27 14:26:04 [INFO] Stored Issuer revocation public key at /home/judy/go/src/github.com/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/IssuerRevocationPublicKey
      ```

    - ![pic8.png](pic8.png)

    - 複製config.yaml到admin的msp/底下

  - config.yaml會放到各身份類型中的msp/底下

- 

