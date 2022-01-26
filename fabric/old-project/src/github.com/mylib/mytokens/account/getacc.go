package account

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

type GetAccount struct {
	APIstub shim.ChaincodeStubInterface
}

func (g *GetAccount) MemberAllowance(myaccount string, hisaccount string) []byte {

	var allowanceMemberResp = make(map[string]interface{})
	allowanceMemberResp["myaccount"] = myaccount
	allowanceMemberResp["hisaccount"] = hisaccount

	e := erc20.Erc20{
		g.APIstub,
	}
	value, errmsg, isOk := e.Allowance(myaccount, hisaccount)
	if isOk {
		allowanceMemberResp["value"] = value
		allowanceMemberResp["errmessage"] = ""
		allowanceMemberResp["returncode"] = true
	} else {
		allowanceMemberResp["value"] = 0
		allowanceMemberResp["errmessage"] = errmsg
		allowanceMemberResp["returncode"] = false
	}

	mapResp, _ := json.Marshal(allowanceMemberResp)
	return mapResp

}

func (g *GetAccount) MemberBalanceOf(account string) []byte {

	var memberBalanceResp = make(map[string]interface{})

	e := erc20.Erc20{
		g.APIstub,
	}
	value, errmsg, isOk := e.BalanceOf(account)
	if isOk {
		mapMember, _ := json.Marshal(value)
		return mapMember
	} else {
		memberBalanceResp["errmessage"] = errmsg
		mapResp, _ := json.Marshal(memberBalanceResp)
		return mapResp
	}

}

func (g *GetAccount) GetHistoryOfAccount(account string) []byte {

	resultsIterator, err := g.APIstub.GetHistoryForKey(account)
	if err != nil {
		return []byte(msg.FailedToGetMemberAccount + err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return []byte(msg.FailedToGetMemberAccount + err.Error())
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
