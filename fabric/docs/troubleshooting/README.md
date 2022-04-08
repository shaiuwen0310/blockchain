# troubleshooting
### on fabric 2.2.4
* 在peer節點log上出現error字眼，但交易成功 
```log
2022-04-08 11:53:44.874 CST [comm.grpc.server] 1 -> INFO 056 streaming call completed grpc.service=protos.Deliver grpc.method=DeliverFiltered grpc.peer_address=192.168.9.10:60184 grpc.peer_subject="CN=fabric-common" error="context finished before block retrieved: context canceled" grpc.code=Unknown grpc.call_duration=3.614366551s
```
查詢 [how-to-fix-context-finished-before-block-retrieved-context-canceled-occurred](https://stackoverflow.com/questions/55733319/how-to-fix-context-finished-before-block-retrieved-context-canceled-occurred)，回覆表示是正常狀況：
```
This is not an error. You are using an SDK that connects to the peer and waits for the instantiate to finish. The block is received by the peer, and when it does - the SDK closes the gRPC stream because it doesn't need it anymore, and the peer logs this to notify you why it closed the stream from the server side.
```

