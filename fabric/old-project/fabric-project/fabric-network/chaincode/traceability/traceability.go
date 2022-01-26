package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"math/rand"
	"strconv"
	"strings"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

type traceAbility struct {
	ProductName     string `json:"productName"`
	ProduceDate     string `json:"produceDate"`
	OperateDate     string `json:"operateDate"`
	ProductQuantity string `json:"productQuantity"`
	// InfoPicture     string              `json:"infoPicture"`
	PicHash        string              `json:"picHash"`
	Account        string              `json:"account"`
	Txid           string              `json:"txid"`
	TrackingNumber map[string][]string `json:"trackingNumber"`
	ImgName        string              `json:"imgName"`
}

type traceInfoRes struct {
	ProductName     string `json:"productName"`
	ProduceDate     string `json:"produceDate"`
	ProductQuantity string `json:"productQuantity"`
	Account         string `json:"account"`
	OperateDate     string `json:"operateDate"`
}

type trackingInfo struct {
	TrackingNumber string `json:"trackingnumber"`
	ProductToken   string `json:"producttoken"`
}

/*
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
CORE_PEER_ADDRESS=peer0.org1.example.com:7051
PEER_CONN_PARMS="--peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${PEER0_ORG1_CA}"
orderer=orderer.example.com:7050
cc=traceabilitycc
peer chaincode invoke -o $orderer --tls true --cafile $ORDERER_CA -C mychannel -n $cc $PEER_CONN_PARMS -c '{"Args":["set", "Aegis combat system", "20180101", "20190101", "10", "QWVnaXMgY29tYmF0IHN5c3RlbQ==", "Lockheed Martin", "736df107b4d99cd5aa400eba7bd043755001ca8d5d47e408d33ac618765ebe1d"]}'
peer chaincode invoke -o $orderer --tls true --cafile $ORDERER_CA -C mychannel -n $cc $PEER_CONN_PARMS -c '{"Args":["set", "Aegis combat system", "20180202", "20190202", "20", "QWVnaXMgY29tYmF0IHN5c3RlbQ==", "Lockheed Martin", "736df107b4d99cd5aa400eba7bd043755001ca8d5d47e408d33ac618765ebe1d"]}'
peer chaincode invoke -o $orderer --tls true --cafile $ORDERER_CA -C mychannel -n $cc $PEER_CONN_PARMS -c '{"Args":["set", "Trident missile", "20180303", "20190303", "30", "VHJpZGVudCBtaXNzaWxl", "Lockheed Martin", "bc5d923c41f2f2d761f74c49e454e00274635ea35bc898f75696b792e2a296ca"]}'
peer chaincode invoke -o $orderer --tls true --cafile $ORDERER_CA -C mychannel -n $cc $PEER_CONN_PARMS -c '{"Args":["verify", "3181cac6809b2c5b91543ecb54c50cab9f7eefbb79088470d6791d206246dea5", "20180101246dea503"]}'
peer chaincode invoke -o $orderer --tls true --cafile $ORDERER_CA -C mychannel -n $cc $PEER_CONN_PARMS -c '{"Args":["quantity", "Aegis combat system"]}'
peer chaincode invoke -o $orderer --tls true --cafile $ORDERER_CA -C mychannel -n $cc $PEER_CONN_PARMS -c '{"Args":["checkbyhash", "736df107b4d99cd5aa400eba7bd043755001ca8d5d47e408d33ac618765ebe1d"]}'
peer chaincode invoke -o $orderer --tls true --cafile $ORDERER_CA -C mychannel -n $cc $PEER_CONN_PARMS -c '{"Args":["del", "Aegis combat system", "20180101", "20190101"]}'
*/

type SmartContract struct {
}

func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {

	_, args := APIstub.GetFunctionAndParameters()
	if len(args) != 1 {
		return shim.Error("Incorrect arguments. Expecting TimeZone")
	}
	err := APIstub.PutState("TIMEZONE", []byte(args[0]))
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to create TimeZone: %s", args[0]))
	}
	return shim.Success([]byte(args[0]))
}

func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	function, args := APIstub.GetFunctionAndParameters()

	if function == "set" {
		return s.Set(APIstub, args)
	} else if function == "verify" {
		return s.Verify(APIstub, args)
	} else if function == "quantity" {
		return s.Quantity(APIstub, args)
	} else if function == "checkbyhash" {
		return s.checkByHash(APIstub, args)
	} else if function == "del" {
		return s.Del(APIstub, args)
	}
	return shim.Error("Invalid Smart Contract function name. " + function)
}

func padZero(n int) string {
	var str string
	for i := 0; i < n; i++ {
		str = str + "0"
	}
	return str
}

func (s *SmartContract) Set(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var setResp = make(map[string]interface{})
	setResp["isOk"] = false
	setResp["rtn"] = nil
	setResp["txid"] = nil
	setResp["productInfo"] = nil

	if len(args) != 7 {
		setResp["rtn"] = 11
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	productname := args[0]
	producedate := args[1]
	operatedate := args[2]
	productquantity := args[3]
	// infopicture := args[4]
	account := args[4]
	pichash := args[5]
	imgname := args[6]

	//檢查是否有key值
	KeyValue := productname + producedate + operatedate
	KeyAsBytes, err := APIstub.GetState(KeyValue)
	if err != nil {
		setResp["rtn"] = 12 //抓取資料時系統異常
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	} else if KeyAsBytes != nil {
		setResp["rtn"] = 13 //已有此key值 故無法再塞資料
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	txid := APIstub.GetTxID()
	last7 := string(txid[len(txid)-7:])
	fmt.Println(last7)

	trackingnumber := make(map[string][]string)
	quantityNumber, err := strconv.Atoi(productquantity)
	quantityLen := len(productquantity)
	PinArr := make([]string, quantityNumber)
	trackingInfo := make([]trackingInfo, quantityNumber)
	for i := 0; i < quantityNumber; i++ {
		strNumber := strconv.Itoa(i + 1)
		strNumberLen := len(strNumber)
		paddingzeroLen := quantityLen - strNumberLen
		pin := producedate + last7 + padZero(paddingzeroLen) + strNumber
		PinArr[i] = pin

		rand.Seed(time.Now().UnixNano())
		x := rand.Intn(9999999)
		save := x + 17

		trackingnumber[PinArr[i]] = append(trackingnumber[PinArr[i]], "0")
		trackingnumber[PinArr[i]] = append(trackingnumber[PinArr[i]], strconv.Itoa(save))
		trackingInfo[i].ProductToken = strconv.Itoa(x)
		trackingInfo[i].TrackingNumber = pin
		//0為驗證日期 1為token
		// fmt.Println(trackingnumber[PinArr[i]][0])
		// fmt.Println(trackingnumber[PinArr[i]][1])
	}

	var traceability = traceAbility{ProductName: productname, ProduceDate: producedate, OperateDate: operatedate,
		ProductQuantity: productquantity, Account: account, Txid: txid, PicHash: pichash,
		TrackingNumber: trackingnumber, ImgName: imgname}
	traceabilityAsBytes, _ := json.Marshal(traceability)
	APIstub.PutState(KeyValue, traceabilityAsBytes)

	setResp["isOk"] = true
	setResp["rtn"] = 0
	setResp["txid"] = txid
	setResp["productInfo"] = trackingInfo
	mapResp, _ := json.Marshal(setResp)
	return shim.Success(mapResp)

}

func (s *SmartContract) Verify(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var setResp = make(map[string]interface{})
	setResp["isOk"] = false
	setResp["rtn"] = nil
	setResp["verifyFlag"] = nil
	setResp["verifyDate"] = nil
	setResp["verifyTime"] = nil
	setResp["picHash"] = nil
	setResp["imgName"] = nil

	if len(args) != 3 {
		setResp["rtn"] = 11
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	txid := args[0]
	trackingnumber := args[1]
	producttoken := args[2]
	setResp["trackingNumber"] = trackingnumber
	queryString := fmt.Sprintf("{\"selector\":{\"txid\":\"%s\"}}", txid)

	tz, err := APIstub.GetState("TIMEZONE")
	if err != nil {
		setResp["rtn"] = 12 //抓取資料時系統異常
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	} else if tz == nil {
		setResp["rtn"] = 19 //無時區資料
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	resultsIterator, err := APIstub.GetQueryResult(queryString)
	if err != nil {
		setResp["rtn"] = 12
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			setResp["rtn"] = 12
			mapResp, _ := json.Marshal(setResp)
			return shim.Success(mapResp)
		}

		v := traceAbility{}
		err = json.Unmarshal(queryResponse.Value, &v)
		keyValue := v.ProductName + v.ProduceDate + v.OperateDate
		trackingMap := v.TrackingNumber

		if trackingMap[trackingnumber][0] == "" {
			setResp["rtn"] = 16
			mapResp, _ := json.Marshal(setResp)
			return shim.Success(mapResp)
		}

		num, _ := strconv.Atoi(producttoken)
		if trackingMap[trackingnumber][1] != strconv.Itoa(num+17) {
			setResp["rtn"] = 20
			mapResp, _ := json.Marshal(setResp)
			return shim.Success(mapResp)
		}

		if trackingMap[trackingnumber][0] == "0" {

			// err := godotenv.Load()
			// dir, err := os.Getwd()
			// if err != nil {
			// 	log.Fatal(err)
			// }
			// fmt.Println(dir)
			// if err != nil {
			// 	fmt.Println(err)
			// 	setResp["rtn"] = 19
			// 	mapResp, _ := json.Marshal(setResp)
			// 	return shim.Success(mapResp)
			// }
			// tz := os.Getenv("TIMEZONE")

			local, err := time.LoadLocation(string(tz))
			if err != nil {
				fmt.Println(err)
			}

			nowRight := time.Now().In(local).Format("2006/01/02 15:04:05")

			setResp["verifyFlag"] = 0               //未驗證過 現在是第一次驗證
			setResp["verifyDate"] = nowRight[0:10]  //現在驗證日期
			setResp["verifyTime"] = nowRight[11:19] //現在驗證時間
			setResp["picHash"] = v.PicHash
			setResp["imgName"] = v.ImgName

			v.TrackingNumber[trackingnumber][0] = nowRight
			updateAsBytes, _ := json.Marshal(v)
			APIstub.PutState(keyValue, updateAsBytes) //儲存現在驗證日期時間
		} else {
			setResp["verifyFlag"] = 1                                     //之前已驗證過 現在是重複驗證
			setResp["verifyDate"] = trackingMap[trackingnumber][0][0:10]  //第一次驗證的日期
			setResp["verifyTime"] = trackingMap[trackingnumber][0][11:19] //第一次驗證的時間
			setResp["picHash"] = v.PicHash
			setResp["imgName"] = v.ImgName
		}
		setResp["isOk"] = true
		setResp["rtn"] = 0
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	setResp["rtn"] = 17
	mapResp, _ := json.Marshal(setResp)
	return shim.Success(mapResp)
}

func (s *SmartContract) Quantity(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var setResp = make(map[string]interface{})
	setResp["isOk"] = false
	setResp["rtn"] = nil
	setResp["result"] = nil

	if len(args) != 1 {
		setResp["rtn"] = 11
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	productname := args[0]
	queryString := fmt.Sprintf("{\"selector\":{\"productName\":\"%s\"}}", productname)

	queryResults, err, rtn := getQueryResultForQueryString(APIstub, queryString)
	if rtn != "0" {
		setResp["rtn"] = rtn
		mapResp, _ := json.Marshal(setResp)
		fmt.Println("get function: ", err)
		return shim.Success(mapResp)
	}

	res := []traceInfoRes{}
	json.Unmarshal(queryResults, &res)

	setResp["isOk"] = true
	setResp["rtn"] = rtn
	setResp["result"] = res
	mapResp, _ := json.Marshal(setResp)
	return shim.Success(mapResp)

}

// =========================================================================================
// getQueryResultForQueryString executes the passed in query string.
// Result set is built and returned as a byte array containing the JSON results.
// =========================================================================================
func getQueryResultForQueryString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error, string) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)

	resultsIterator, err := stub.GetQueryResult(queryString)
	if err != nil {
		return nil, err, "12"
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return nil, err, "12"
	}

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", buffer.String())

	if buffer.String() == "[]" {
		return buffer.Bytes(), nil, "15"
	} else {
		return buffer.Bytes(), nil, "0"
	}
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

		v := traceAbility{}
		err = json.Unmarshal(queryResponse.Value, &v)

		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"productName\":")
		buffer.WriteString("\"")
		buffer.WriteString(v.ProductName)
		buffer.WriteString("\"")

		buffer.WriteString(", \"produceDate\":")
		buffer.WriteString("\"")
		buffer.WriteString(v.ProduceDate)
		buffer.WriteString("\"")

		buffer.WriteString(", \"operateDate\":")
		buffer.WriteString("\"")
		buffer.WriteString(v.OperateDate)
		buffer.WriteString("\"")

		buffer.WriteString(", \"productQuantity\":")
		buffer.WriteString("\"")
		buffer.WriteString(v.ProductQuantity)
		buffer.WriteString("\"")

		buffer.WriteString(", \"account\":")
		buffer.WriteString("\"")
		buffer.WriteString(v.Account)
		buffer.WriteString("\"")
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return &buffer, nil
}

func (s *SmartContract) checkByHash(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var setResp = make(map[string]interface{})
	setResp["isOk"] = false
	setResp["rtn"] = nil
	setResp["operateDate"] = nil
	setResp["productName"] = nil

	if len(args) != 1 {
		setResp["rtn"] = 11
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	//輸入參數
	pichash := args[0]
	queryString := fmt.Sprintf("{\"selector\":{\"picHash\":\"%s\"}}", pichash)

	resultsIterator, err := APIstub.GetQueryResult(queryString)
	if err != nil {
		setResp["rtn"] = 12
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}
	defer resultsIterator.Close()

	productname := ""
	strOperateDate := ""
	flag := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			setResp["rtn"] = 12
			mapResp, _ := json.Marshal(setResp)
			return shim.Success(mapResp)
		}

		if flag == true {
			strOperateDate = strOperateDate + ";"
		}

		v := traceAbility{}
		err = json.Unmarshal(queryResponse.Value, &v)
		productname = v.ProductName
		strOperateDate = strOperateDate + v.OperateDate
		flag = true
	}

	if flag == false {
		setResp["rtn"] = 18
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	var splits = strings.Split(strOperateDate, ";")
	OperateDateArr := make([]string, len(splits))
	for i := 0; i < len(splits); i++ {
		OperateDateArr[i] = splits[i]
	}

	setResp["isOk"] = true
	setResp["rtn"] = 0
	setResp["operateDate"] = OperateDateArr
	setResp["productName"] = productname
	mapResp, _ := json.Marshal(setResp)
	return shim.Success(mapResp)
}

func (s *SmartContract) Del(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	var setResp = make(map[string]interface{})
	setResp["isOk"] = false
	setResp["rtn"] = nil
	setResp["productName"] = nil

	if len(args) != 3 {
		setResp["rtn"] = 11
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	productname := args[0]
	producedate := args[1]
	operatedate := args[2]
	setResp["productName"] = productname

	//檢查是否有key值
	KeyValue := productname + producedate + operatedate
	KeyAsBytes, err := APIstub.GetState(KeyValue)
	if err != nil {
		setResp["rtn"] = 12 //抓取資料時系統異常
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	} else if KeyAsBytes == nil {
		setResp["rtn"] = 14 //無此key值 故無法刪除資料
		mapResp, _ := json.Marshal(setResp)
		return shim.Success(mapResp)
	}

	err = APIstub.DelState(KeyValue)
	if err != nil {
		setResp["rtn"] = 12
	} else {
		setResp["isOk"] = true
		setResp["rtn"] = 0
	}

	mapResp, _ := json.Marshal(setResp)
	return shim.Success(mapResp)

}

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
