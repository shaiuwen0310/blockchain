package main

/*
1. see https://godoc.org/github.com/blockc/fabric/core/chaincode/shim
2. fmt.Println("display: ", a) --> 才可以在docker logs <CCimages> 看到display
3. make(map[string]interface{}) --> json格式的 response
4. compositeIndexName := "txID~time~hash~device" --> 查詢時，必須從第一個鍵值開始給起，故給參數時只會有三種方式，並且依照順序：
	(1) 給txid, time(此合約只提供這種方式)
	(2) 給txid, time, hash
	(3) 給txid, time, hash, device
5. time, _ := APIstub.GetTxTimestamp()
	(1) fmt.Println("time.Seconds:", time.Seconds) //int64
	(2) fmt.Println("time.Nanos:", time.Nanos) //int32
6. rtnc
	(1) 11: 參數個數不對
	(2) 12: CreateCompositeKey時出錯
	(3) 13: PutState時出錯
	(4) 14: GetStateByPartialCompositeKey時出錯
	(5) 15: GetStateByPartialCompositeKey時無此交易
	(6) 16: 獲取Iterator的結果失敗
	(7) 17: SplitCompositeKey時出錯
*/

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

type SmartContract struct {
}

func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	function, args := APIstub.GetFunctionAndParameters()

	if function == "set" {
		return s.Set(APIstub, args)
	} else if function == "get" {
		return s.get(APIstub, args)
	}
	return shim.Error("Invalid Smart Contract function name. " + function)
}

func (s *SmartContract) Set(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var setResp = make(map[string]interface{})
	setResp["txid"] = nil
	setResp["time"] = nil

	if len(args) != 2 {
		setResp["rtnc"] = 11
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	hash := args[0]
	device := args[1]

	//設定response必回欄位
	setResp["hash"] = hash
	setResp["device"] = device

	//取得當下交易id及timestamp
	txid := APIstub.GetTxID()
	time, _ := APIstub.GetTxTimestamp()
	strTime := strconv.FormatInt(time.Seconds, 10)// int64 to string

	//建立複合鍵(Composite Key)
	compositeIndexName := "txID~time~hash~device"
	compositeKey, compositeErr := APIstub.CreateCompositeKey(compositeIndexName, []string{txid, strTime, hash, device})
	if compositeErr != nil {
		setResp["rtnc"] = 12
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	//保存組合鍵index
	compositePutErr := APIstub.PutState(compositeKey, []byte{0x00}) //value:0
	if compositePutErr != nil {
		setResp["rtnc"] = 13
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	//成功才回txid及時間戳
	setResp["txid"] = txid
	setResp["time"] = time.Seconds
	setResp["rtnc"] = 0
	mapResp, _ := json.Marshal(setResp)
	return shim.Success(mapResp)
}


func (s *SmartContract) get(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var getResp = make(map[string]interface{})
	getResp["hash"] = nil
	getResp["device"] = nil

	if len(args) != 2 {
		getResp["rtnc"] = 11
		mapResp, _ := json.Marshal(getResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	txid := args[0]
	time := args[1]

	getResp["txid"] = txid
	getResp["time"] = time

	//透過給定部份複合鍵(Composite Key) 來查詢帳本狀態
	compositeIndexName := "txID~time~hash~device"
	deltaResultsIterator, deltaErr := APIstub.GetStateByPartialCompositeKey(compositeIndexName, []string{txid, time})
	if deltaErr != nil {
		getResp["rtnc"] = 14
		mapResp, _ := json.Marshal(getResp)
		return shim.Success(mapResp)
	}
	defer deltaResultsIterator.Close()

	//確認是否有此筆交易
	if !deltaResultsIterator.HasNext() {
		getResp["rtnc"] = 15
		mapResp, _ := json.Marshal(getResp)
		return shim.Success(mapResp)
	}

	var i int
	var hash, device string
	//Iterate through result set 
	for i = 0; deltaResultsIterator.HasNext(); i++ {
		responseRange, nextErr := deltaResultsIterator.Next()
		if nextErr != nil {
			getResp["rtnc"] = 16
			mapResp, _ := json.Marshal(getResp)
			return shim.Success(mapResp)
		}

		// Split the composite key into its component parts
		_, keyParts, splitKeyErr := APIstub.SplitCompositeKey(responseRange.Key)
		if splitKeyErr != nil {
			getResp["rtnc"] = 17
			mapResp, _ := json.Marshal(getResp)
			return shim.Success(mapResp)
		}

		hash = keyParts[2]
		device = keyParts[3]

	}

	getResp["hash"] = hash
	getResp["device"] = device
	getResp["rtnc"] = 0
	mapResp, _ := json.Marshal(getResp)
	return shim.Success(mapResp)
}


func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
