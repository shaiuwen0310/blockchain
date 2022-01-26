/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/*
 * The sample smart contract for documentation topic:
 * Writing Your First Blockchain Application
 * 可能需要設定有哪些欄位是可以修改的
 */

/*
peer chaincode invoke -n mycc -c '{"Args":["createWine", "NAME1", "Place1", "81", "AAA001", "taste1", "red1", "total1"]}' -C myc
peer chaincode invoke -n mycc -c '{"Args":["createWine", "NAME2", "Place2", "82", "AAA001", "taste2", "red2", "total2"]}' -C myc
peer chaincode invoke -n mycc -c '{"Args":["createWine", "NAME3", "Place3", "83", "AAA001", "taste3", "red3", "total3"]}' -C myc
peer chaincode invoke -n mycc -c '{"Args":["createWine", "NAME4", "Place4", "84", "AAA001", "taste4", "red4", "total4"]}' -C myc
peer chaincode invoke -n mycc -c '{"Args":["createWine", "NAME5", "Place5", "85", "AAA001", "taste5", "red5", "total5"]}' -C myc

peer chaincode query -n mycc -c '{"Args":["queryWine", "judy-wine-NAME1"]}' -C myc

peer chaincode query -n mycc -c '{"Args":["getHistoryForWine", "judy-wine-NAME1"]}' -C myc

peer chaincode query -n mycc -c '{"Args":["queryWineByPlace", "Place2"]}' -C myc

peer chaincode invoke -n mycc -c '{"Args":["createWinefromJsonFile", "{\"name\": \"a\",\"place\": \"Place1\",\"year\": \"c\",\"winerymbr\": \"AAA001\",\"taste\": \"e\",\"color\": \"f\",\"yield\": \"g\"}"]}' -C myc
peer chaincode query -n mycc -c '{"Args":["queryWine", "judy-wine-a"]}' -C myc
peer chaincode query -n mycc -c '{"Args":["queryWineByPlace", "Place1"]}' -C myc

peer chaincode query -n mycc -c '{"Args":["queryWinesWithPagination", "{\"selector\":{\"winerymbr\":\"AAA001\"}}", "3", ""]}' -C myc
*/

package main

/* Imports
 * 4 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	// "strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Define the Smart Contract structure
type SmartContract struct {
}

// Define the Wine structure, with 7 properties.  Structure tags are used by encoding/json library
type Wine struct {
	Name      string `json:"name"`
	Place     string `json:"place"`
	Year      string `json:"year"`
	Winerymbr string `json:"winerymbr"`
	Taste     string `json:"taste"`
	Color     string `json:"color"`
	Yield     string `json:"yield"`
}

/*
 * The Init method is called when the Smart Contract "fabcar" is instantiated by the blockchain network
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "fabcar"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "queryWine" {
		return s.queryWine(APIstub, args)
	} else if function == "createWine" {
		return s.createWine(APIstub, args)
	} else if function == "getHistoryForWine" {
		return s.getHistoryForWine(APIstub, args)
	} else if function == "queryWineByPlace" {
		return s.queryWineByPlace(APIstub, args)
	} else if function == "createWinefromJsonFile" {
		return s.createWinefromJsonFile(APIstub, args)
	} else if function == "queryWinesWithPagination" {
		return s.queryWinesWithPagination(APIstub, args)
	} else if function == "deleteWineBYkey" {
		return s.deleteWineBYkey(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

/*
 * 抓取一筆key-value資料
 * 利用key值抓取value，取出的value應該要是json
 */
func (s *SmartContract) queryWine(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	wineAsBytes, _ := APIstub.GetState(args[0]) //judy-wine-酒名
	return shim.Success(wineAsBytes)
}

/*
 * 儲存一筆key-value資料
 * 自行將欄位組成json後，當成value儲存
 * 可以自行對欄位做檢核，如該欄位必定為數字
 */
func (s *SmartContract) createWine(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	//the Wine structure with 7 properties
	if len(args) != 7 {
		return shim.Error("Incorrect number of arguments. Expecting 7")
	}

	winekey := "judy-wine-" + args[0] //自己組key值，judy-wine-酒名

	//檢查這個key值是否已存在
	checkWineAsBytes, err := APIstub.GetState(winekey)
	if err != nil {
		return shim.Error("Failed to get marble: " + err.Error())
	} else if checkWineAsBytes != nil {
		fmt.Println("This marble already exists: " + winekey)
		return shim.Error("This marble already exists: " + winekey)
	}

	var wine = Wine{Name: args[0], Place: args[1], Year: args[2], Winerymbr: args[3], Taste: args[4], Color: args[5], Yield: args[6]}

	wineAsBytes, _ := json.Marshal(wine)
	APIstub.PutState(winekey, wineAsBytes)

	return shim.Success(nil)
}

/*
 * 儲存一筆key-value資料
 * 輸入的的資料本身就是json
 * json file格式須跟Wine struct一致
 */
func (s *SmartContract) createWinefromJsonFile(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	//1個欄位，因為是json格式
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	// wineAsBytes, _ := json.Marshal(wine)
	wineAsBytes := []byte(args[0])
	var wine Wine
	err := json.Unmarshal(wineAsBytes, &wine)
	if err != nil {
		fmt.Println("error in translating,", err.Error())
	}
	fmt.Println("key: ", wine.Name)
	winekey := "judy-wine-" + wine.Name //自己組key值，judy-wine-酒名
	APIstub.PutState(winekey, wineAsBytes)

	return shim.Success(nil)
}

/*
 * 抓取一筆key-value從第一版到最新版的所有資料
 * 可任意挑選要抓取的欄位
 */
func (s *SmartContract) getHistoryForWine(stub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	winekey := args[0]

	fmt.Printf("- start getHistoryForWine: %s\n", winekey)

	resultsIterator, err := stub.GetHistoryForKey(winekey)
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

/*
 * 富查詢(couchDB only)
 * 可透過value中的欄位來抓取符合的資料(類似select from where的where)
 * selector中的欄位可以多個
 * 無須設置index
 */
func (t *SmartContract) queryWineByPlace(stub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	// place := strings.ToLower(args[0])
	place := args[0]

	queryString := fmt.Sprintf("{\"selector\":{\"place\":\"%s\"}}", place)

	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

// =========================================================================================
// getQueryResultForQueryString executes the passed in query string.
// Result set is built and returned as a byte array containing the JSON results.
// =========================================================================================
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

/*
 * 具有分頁功能的富查詢(couchDB only)
 * args: 搜尋關鍵字(富查詢)，顯示幾筆資料，標籤(下次查詢帶此標籤，往下查詢)
 * 類似實作查詢明細的方式
 */
func (s *SmartContract) queryWinesWithPagination(stub shim.ChaincodeStubInterface, args []string) sc.Response {

	//   0
	// "queryString"
	if len(args) < 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}

	queryString := args[0]
	//return type of ParseInt is int64
	pageSize, err := strconv.ParseInt(args[1], 10, 32)
	if err != nil {
		return shim.Error(err.Error())
	}
	bookmark := args[2]

	queryResults, err := getQueryResultForQueryStringWithPagination(stub, queryString, int32(pageSize), bookmark)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

// ===========================================================================================
// addPaginationMetadataToQueryResults adds QueryResponseMetadata, which contains pagination
// info, to the constructed query results
// ===========================================================================================
func addPaginationMetadataToQueryResults(buffer *bytes.Buffer, responseMetadata *sc.QueryResponseMetadata) *bytes.Buffer {

	buffer.WriteString("[{\"ResponseMetadata\":{\"RecordsCount\":")
	buffer.WriteString("\"")
	buffer.WriteString(fmt.Sprintf("%v", responseMetadata.FetchedRecordsCount))
	buffer.WriteString("\"")
	buffer.WriteString(", \"Bookmark\":")
	buffer.WriteString("\"")
	buffer.WriteString(responseMetadata.Bookmark)
	buffer.WriteString("\"}}]")

	return buffer
}

// ===========================================================================================
// constructQueryResponseFromIterator constructs a JSON array containing query results from
// a given result iterator
// ===========================================================================================
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

// =========================================================================================
// getQueryResultForQueryStringWithPagination executes the passed in query string with
// pagination info. Result set is built and returned as a byte array containing the JSON results.
// =========================================================================================
func getQueryResultForQueryStringWithPagination(stub shim.ChaincodeStubInterface, queryString string, pageSize int32, bookmark string) ([]byte, error) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)

	resultsIterator, responseMetadata, err := stub.GetQueryResultWithPagination(queryString, pageSize, bookmark)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return nil, err
	}

	bufferWithPaginationInfo := addPaginationMetadataToQueryResults(buffer, responseMetadata)

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", bufferWithPaginationInfo.String())

	return buffer.Bytes(), nil
}

/*
 * 刪除一筆資料
 */
func (s *SmartContract) deleteWineBYkey(stub shim.ChaincodeStubInterface, args []string) sc.Response {

	//key值
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	err := stub.DelState(args[0])
	if err != nil {
		return shim.Error("Failed to delete state")
	}
	return shim.Success(nil)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
