package token

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/mylib/mytokens/erc20"
	"github.com/mylib/mytokens/msg"
)

type GetToken struct {
	APIstub shim.ChaincodeStubInterface
}

func (g *GetToken) GetTokenInfo(tokenname string) []byte {

	//檢查是否有這個token
	tokenKeyAsBytes, err := g.APIstub.GetState(tokenname)
	if err != nil {
		return []byte(msg.FailedToGetToken + err.Error())
	} else if tokenKeyAsBytes == nil {
		return []byte(msg.ThisTokenIsNotExists + tokenname)
	}
	return tokenKeyAsBytes
}

func (g *GetToken) GetTokenSupplyTotal(tokenname string) []byte {

	var GetTokenSupplyResp = make(map[string]interface{})
	GetTokenSupplyResp["tokenname"] = tokenname

	i := erc20.Erc20{
		g.APIstub,
	}

	result, errmsg, isOk := i.TotalSupply(tokenname)
	if isOk {
		GetTokenSupplyResp["errmessage"] = ""
		GetTokenSupplyResp["result"] = result
		GetTokenSupplyResp["returncode"] = true
		mapToken, _ := json.Marshal(GetTokenSupplyResp)
		return mapToken
	} else {
		GetTokenSupplyResp["errmessage"] = errmsg
		GetTokenSupplyResp["result"] = ""
		GetTokenSupplyResp["returncode"] = false
		mapToken, _ := json.Marshal(GetTokenSupplyResp)
		return mapToken
	}
}

func (g *GetToken) GetHistoryOfTokenAccount(tokenname string, tokenaccount string) []byte {

	resultsIterator, err := g.APIstub.GetHistoryForKey(tokenname + tokenaccount)
	if err != nil {
		return []byte(msg.FailedToGetTokenAccount + err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return []byte(msg.FailedToGetTokenAccount + err.Error())
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

	return buffer.Bytes()
}
