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

type snsrData struct {
	Content string `json:"content"`
	Txid    string `json:"txid"`
}

type SmartContract struct {
}

func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	function, args := APIstub.GetFunctionAndParameters()

	if function == "set" {
		return s.Set(APIstub, args)
	} else if function == "vhist" {
		return s.vHist(APIstub, args)
	}
	return shim.Error("Invalid Smart Contract function name. " + function)
}

func (s *SmartContract) Set(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var setResp = make(map[string]interface{})
	setResp["context"] = nil
	setResp["txid"] = nil

	if len(args) != 2 {
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	key := args[0]
	content := args[1]
	txid := APIstub.GetTxID()

	var strInfo = snsrData{Content: content, Txid: txid}
	strInfoAsBytes, _ := json.Marshal(strInfo)
	APIstub.PutState(key, strInfoAsBytes)

	setResp["context"] = content
	setResp["txid"] = txid
	mapResp, _ := json.Marshal(setResp)
	return shim.Success(mapResp)

}

// func (s *SmartContract) vTxid(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

// 	if len(args) < 1 {
// 		return shim.Error("Incorrect number of arguments. Expecting 1")
// 	}

// 	// place := strings.ToLower(args[0])
// 	txid := args[0]

// 	queryString := fmt.Sprintf("{\"selector\":{\"txid\":\"%s\"}}", txid)

// 	queryResults, err := getQueryResultForQueryString(APIstub, queryString)
// 	if err != nil {
// 		return shim.Error(err.Error())
// 	}
// 	return shim.Success(queryResults)

// }

func getQueryResultForQueryString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)

	resultsIterator, err := stub.GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return nil, err
	}

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", buffer.String())

	return buffer.Bytes(), nil
}

func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) (*bytes.Buffer, error) {
	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return &buffer, nil
}

func (s *SmartContract) vHist(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	key := args[0]

	fmt.Printf("- start getHistoryForWine: %s\n", key)

	resultsIterator, err := APIstub.GetHistoryForKey(key)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
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

	fmt.Printf("- getHistoryForWine returning:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())

}

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
