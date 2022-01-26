package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

//儲存檔案名稱
type storeHash struct {
	Title        string `json:"title"`
	Txid         string `json:"txid"`
	Userid       string `json:"userid"`
	Time         string `json:"time"`
	Name         string `json:"name"`
	Serialnumber string `json:"serialnumber"`
	TheLast7     string `json:"thelast7"`
}

type SerialNumber struct {
	Num string `json:"num"`
}

var snumInt uint64 = 0
var NumStr string = ""

type SmartContract struct {
}

func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	function, args := APIstub.GetFunctionAndParameters()

	if function == "set" {
		return s.Set(APIstub, args)
	} else if function == "vtxid" {
		return s.vTxid(APIstub, args)
	} else if function == "vhash" {
		return s.vHash(APIstub, args)
	} else if function == "vserialno" {
		return s.vSerialno(APIstub, args)
	} else if function == "gethistory" {
		return s.getHistory(APIstub, args)
	} else if function == "vserialnoblockid" {
		return s.vSerialnoBlockId(APIstub, args)
	}
	return shim.Error("Invalid Smart Contract function name. " + function)
}

func (s *SmartContract) Set(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var setResp = make(map[string]interface{})
	setResp["isOk"] = false
	setResp["txid"] = nil
	setResp["serialNumber"] = nil
	setResp["blockId"] = nil

	if len(args) != 5 {
		setResp["errcode"] = 11
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	hashvalue := args[0]
	title := args[1]
	time := args[2]
	name := args[3]
	userid := args[4]
	txid := APIstub.GetTxID()
	last7 := string(txid[len(txid)-7:])

	//檢查是否有這個hash值
	hashKeyAsBytes, err := APIstub.GetState(hashvalue)
	if err != nil {
		setResp["errcode"] = 12
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	} else if hashKeyAsBytes != nil {
		setResp["errcode"] = 13
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	//檢查是否有serial number
	snKeyAsBytes, err := APIstub.GetState("SN")
	if err != nil {
		setResp["errcode"] = 12
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	} else if snKeyAsBytes == nil {
		//第一次執行 建立流水號欄位
		var serialnumber = SerialNumber{Num: "1"}
		serialnumberAsBytes, _ := json.Marshal(serialnumber)
		APIstub.PutState("SN", serialnumberAsBytes)
		snumInt = 1
	} else if snKeyAsBytes != nil {
		//第二及之後執行 流水號加一
		tmp := SerialNumber{}
		json.Unmarshal(snKeyAsBytes, &tmp)
		snumInt, _ = strconv.ParseUint(tmp.Num, 10, 64)
		snumInt++
	}
	snumStr := strconv.FormatUint(snumInt, 10)
	var serialnumber = SerialNumber{Num: snumStr}
	serialnumberAsBytes, _ := json.Marshal(serialnumber)
	APIstub.PutState("SN", serialnumberAsBytes)

	var storeInfo = storeHash{Title: title, Txid: txid, Userid: userid, Serialnumber: snumStr, TheLast7: last7, Time: time, Name: name}
	storeInfoAsBytes, _ := json.Marshal(storeInfo)
	APIstub.PutState(hashvalue, storeInfoAsBytes)

	setResp["isOk"] = true
	setResp["errcode"] = 0
	setResp["txid"] = txid
	setResp["serialNumber"] = snumStr
	setResp["blockId"] = last7
	mapResp, _ := json.Marshal(setResp)
	return shim.Success(mapResp)

}

func (s *SmartContract) vTxid(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var vResp = make(map[string]interface{})
	vResp["isOk"] = false

	if len(args) != 1 {
		vResp["errcode"] = 11
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	txid := args[0]

	queryString := fmt.Sprintf("{\"selector\":{\"txid\":\"%s\"}}", txid)
	resultsIterator, err := APIstub.GetQueryResult(queryString)
	if err != nil {
		vResp["errcode"] = 12
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	} else if resultsIterator == nil {
		vResp["errcode"] = 14
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		vResp["isOk"] = true
		vResp["errcode"] = 0
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}

	vResp["errcode"] = 15
	mapResp, _ := json.Marshal(vResp)
	return shim.Success(mapResp)

}

func (s *SmartContract) vHash(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var vResp = make(map[string]interface{})
	vResp["isOk"] = false

	if len(args) != 1 {
		vResp["errcode"] = 11
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	hashvalue := args[0]

	//檢核key值是否存在
	keyAsBytes, err := APIstub.GetState(hashvalue)
	if err != nil {
		vResp["errcode"] = 12
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	} else if keyAsBytes == nil {
		vResp["errcode"] = 14
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}

	vResp["isOk"] = true
	vResp["errcode"] = 0
	mapResp, _ := json.Marshal(vResp)
	return shim.Success(mapResp)

}

func (s *SmartContract) vSerialno(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var vResp = make(map[string]interface{})
	vResp["isOk"] = false

	if len(args) != 1 {
		vResp["errcode"] = 11
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	snumStr := args[0]

	queryString := fmt.Sprintf("{\"selector\":{\"serialnumber\":\"%s\"}}", snumStr)
	resultsIterator, err := APIstub.GetQueryResult(queryString)
	if err != nil {
		vResp["errcode"] = 12
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	} else if resultsIterator == nil {
		vResp["errcode"] = 14
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		fmt.Print(string(queryResponse.Value))

		vResp["isOk"] = true
		vResp["errcode"] = 0
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}

	vResp["errcode"] = 15
	mapResp, _ := json.Marshal(vResp)
	return shim.Success(mapResp)

}

func (s *SmartContract) vSerialnoBlockId(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var vResp = make(map[string]interface{})
	vResp["isOk"] = false

	if len(args) != 2 {
		vResp["errcode"] = 11
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	serialno := args[0]
	blockid := args[1]

	queryString := fmt.Sprintf("{\"selector\":{\"serialnumber\":\"%s\",\"thelast7\":\"%s\"}}", serialno, blockid)
	resultsIterator, err := APIstub.GetQueryResult(queryString)
	if err != nil {
		vResp["errcode"] = 12
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	} else if resultsIterator == nil {
		vResp["errcode"] = 14
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		fmt.Print(string(queryResponse.Value))

		vResp["isOk"] = true
		vResp["errcode"] = 0
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}

	vResp["errcode"] = 15
	mapResp, _ := json.Marshal(vResp)
	return shim.Success(mapResp)

}

// func (s *SmartContract) getHistory(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

// 	var vResp = make(map[string]interface{})
// 	vResp["isOk"] = false

// 	if len(args) != 1 {
// 		vResp["errcode"] = 11
// 		mapResp, _ := json.Marshal(vResp)
// 		return shim.Success(mapResp)
// 	}

// 	//輸入參數
// 	hashvalue := args[0]

// 	resultsIterator, err := APIstub.GetHistoryForKey(hashvalue)
// 	if err != nil {
// 		vResp["errcode"] = 12
// 		mapResp, _ := json.Marshal(vResp)
// 		return shim.Success(mapResp)
// 	}
// 	defer resultsIterator.Close()

// 	// buffer is a JSON array containing historic values for the marble
// 	var buffer bytes.Buffer
// 	buffer.WriteString("[")

// 	bArrayMemberAlreadyWritten := false
// 	for resultsIterator.HasNext() {
// 		response, err := resultsIterator.Next()
// 		if err != nil {
// 			vResp["errcode"] = 12
// 			mapResp, _ := json.Marshal(vResp)
// 			return shim.Success(mapResp)
// 		}
// 		// Add a comma before array members, suppress it for the first array member
// 		if bArrayMemberAlreadyWritten == true {
// 			buffer.WriteString(",")
// 		}
// 		buffer.WriteString("{\"TxId\":")
// 		buffer.WriteString("\"")
// 		buffer.WriteString(response.TxId)
// 		buffer.WriteString("\"")

// 		buffer.WriteString(", \"Value\":")
// 		// if it was a delete operation on given key, then we need to set the
// 		//corresponding value null. Else, we will write the response.Value
// 		//as-is (as the Value itself a JSON marble)
// 		if response.IsDelete {
// 			buffer.WriteString("null")
// 		} else {
// 			buffer.WriteString(string(response.Value))
// 		}

// 		buffer.WriteString(", \"Timestamp\":")
// 		buffer.WriteString("\"")
// 		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
// 		buffer.WriteString("\"")

// 		buffer.WriteString(", \"IsDelete\":")
// 		buffer.WriteString("\"")
// 		buffer.WriteString(strconv.FormatBool(response.IsDelete))
// 		buffer.WriteString("\"")

// 		buffer.WriteString("}")
// 		bArrayMemberAlreadyWritten = true
// 	}
// 	buffer.WriteString("]")

// 	return shim.Success(buffer.Bytes())

// }

func (s *SmartContract) getHistory(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var vResp = make(map[string]interface{})
	vResp["isOk"] = false
	vResp["result"] = nil

	if len(args) != 1 {
		vResp["errcode"] = 11
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	hashvalue := args[0]

	resultsIterator, err := APIstub.GetHistoryForKey(hashvalue)
	if err != nil {
		vResp["errcode"] = 12
		mapResp, _ := json.Marshal(vResp)
		return shim.Success(mapResp)
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			vResp["errcode"] = 12
			mapResp, _ := json.Marshal(vResp)
			return shim.Success(mapResp)
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	vResp["isOk"] = true
	vResp["errcode"] = 0
	vResp["result"] = buffer.String()
	mapResp, _ := json.Marshal(vResp)
	return shim.Success(mapResp)

}

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
