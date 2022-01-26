package transfer

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	. "github.com/mylib/mytokens/data"
	"github.com/mylib/mytokens/erc20"
	"github.com/mylib/mytokens/msg"
)

type Txn struct {
	APIstub shim.ChaincodeStubInterface
}

const (
	notEnable = 0
	isEnable  = 1
	notUse    = 2
	isZERO    = 0
)

func (t *Txn) Transfers(tokenname string, tokenaccount string, memberaccount string, counts uint64, walletid string, choose string) []byte {

	var TransferResp = make(map[string]interface{})
	TransferResp["tokenname"] = tokenname
	TransferResp["tokenaccount"] = tokenaccount
	TransferResp["memberaccount"] = memberaccount
	TransferResp["counts"] = counts

	i := erc20.Erc20{
		t.APIstub,
	}
	errmsg, isOk := i.Transfer(tokenname, tokenaccount, memberaccount, counts, walletid, choose)
	if isOk {
		TransferResp["errmessage"] = ""
		TransferResp["returncode"] = true
	} else {
		TransferResp["errmessage"] = errmsg
		TransferResp["returncode"] = false
	}
	mapResp, _ := json.Marshal(TransferResp)
	return mapResp

}

func (t *Txn) TransferFroms(tokenname string, memberfromaccount string, membertoaccount string, counts uint64, walletid string) []byte {

	var TransFromsResp = make(map[string]interface{})
	TransFromsResp["tokenname"] = tokenname
	TransFromsResp["memberfromaccount"] = memberfromaccount
	TransFromsResp["membertoaccount"] = membertoaccount
	TransFromsResp["counts"] = counts

	i := erc20.Erc20{
		t.APIstub,
	}
	errmsg, isOk := i.TransferFrom(tokenname, memberfromaccount, membertoaccount, counts, walletid)
	if isOk {
		TransFromsResp["errmessage"] = ""
		TransFromsResp["returncode"] = true
	} else {
		TransFromsResp["errmessage"] = errmsg
		TransFromsResp["returncode"] = false
	}
	mapResp, _ := json.Marshal(TransFromsResp)
	return mapResp

}

func (t *Txn) ExchangeToken(memberacc string, holdingtoken string, holdingtokenacc string, holdingtokennumber uint64, exchangetoken string, exchangetokenacc string, walletid string) []byte {

	var ExchangeTokenResp = make(map[string]interface{})
	ExchangeTokenResp["account"] = memberacc
	ExchangeTokenResp["returncode"] = false

	//檢核帳號是否已存在 key:會員帳號
	memberAccKeyAsBytes, err := t.APIstub.GetState(memberacc)
	if err != nil {
		ExchangeTokenResp["errmessage"] = msg.FailedToGetMemberAccount + err.Error()
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	} else if memberAccKeyAsBytes == nil {
		ExchangeTokenResp["errmessage"] = msg.ThisMemberAccountIsNotExists + memberacc
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	}

	//檢核會員持有的token帳號是否存在
	holdingtokenAccAsBytes, err := t.APIstub.GetState(holdingtoken + holdingtokenacc)
	if err != nil {
		ExchangeTokenResp["errmessage"] = msg.FailedToGetTokenAccount + err.Error()
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	} else if holdingtokenAccAsBytes == nil {
		ExchangeTokenResp["errmessage"] = msg.ThisTokenAccountIsNotExists + holdingtoken
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	}

	//檢核會員持有的token是否存在
	holdingtokenAsBytes, err := t.APIstub.GetState(holdingtoken)
	if err != nil {
		ExchangeTokenResp["errmessage"] = msg.FailedToGetToken + err.Error()
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	} else if holdingtokenAsBytes == nil {
		ExchangeTokenResp["errmessage"] = msg.ThisTokenIsNotExists + holdingtoken
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	}

	//檢核會員想兌換的token帳號是否存在
	exchangetokenAccAsBytes, errs := t.APIstub.GetState(exchangetoken + exchangetokenacc)
	if err != nil {
		ExchangeTokenResp["errmessage"] = msg.FailedToGetTokenAccount + errs.Error()
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	} else if exchangetokenAccAsBytes == nil {
		ExchangeTokenResp["errmessage"] = msg.ThisTokenAccountIsNotExists + exchangetoken
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	}

	//檢核會員想兌換的token是否存在
	exchangetokenAsBytes, errs := t.APIstub.GetState(exchangetoken)
	if err != nil {
		ExchangeTokenResp["errmessage"] = msg.FailedToGetToken + errs.Error()
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	} else if exchangetokenAsBytes == nil {
		ExchangeTokenResp["errmessage"] = msg.ThisTokenIsNotExists + exchangetoken
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	}

	//建立用來存資料的空struct
	memberAccInfo := MemberAccount{}
	holdingTokenAccInfo := TokenAccount{}
	holdingTokenInfo := TokenInfo{}
	exchangeTokenAccInfo := TokenAccount{}
	exchangeTokenInfo := TokenInfo{}

	//把取出來的資料放到空strict中
	json.Unmarshal(memberAccKeyAsBytes, &memberAccInfo)
	json.Unmarshal(holdingtokenAccAsBytes, &holdingTokenAccInfo)
	json.Unmarshal(holdingtokenAsBytes, &holdingTokenInfo)
	json.Unmarshal(exchangetokenAccAsBytes, &exchangeTokenAccInfo)
	json.Unmarshal(exchangetokenAsBytes, &exchangeTokenInfo)

	fmt.Println(memberAccInfo.State)
	fmt.Println(memberAccInfo.HoldingTokens)
	fmt.Println(holdingTokenAccInfo.State)
	fmt.Println(holdingTokenInfo.Value)
	fmt.Println(holdingTokenAccInfo.Balance)
	fmt.Println(exchangeTokenAccInfo.State)
	fmt.Println(exchangeTokenInfo.Value)
	fmt.Println(exchangeTokenAccInfo.Balance)
	//取出來的資料中所需要的值
	memberstate := memberAccInfo.State
	memberholding := memberAccInfo.HoldingTokens
	holdingtokenstate := holdingTokenAccInfo.State
	holdingtokenvalue := holdingTokenInfo.Value
	holdingtokenbalance := holdingTokenAccInfo.Balance
	exchangetokenstate := exchangeTokenAccInfo.State
	exchangetokenvalue := exchangeTokenInfo.Value
	exchangetokenbalance := exchangeTokenAccInfo.Balance

	// 檢核所有帳號狀態皆為啟用
	if memberstate != isEnable || holdingtokenstate != isEnable || exchangetokenstate != isEnable {
		ExchangeTokenResp["errmessage"] = msg.OneOfAccountIsNotEnable
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	}

	// 檢核會員持有的holding token數量
	if memberholding[holdingtoken] < holdingtokennumber {
		ExchangeTokenResp["errmessage"] = msg.MembesTokenIsNotEnough
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	}

	// 檢核將要轉換的token餘額是否大於會員要轉換的數量
	if holdingtokenbalance < holdingtokennumber {
		ExchangeTokenResp["errmessage"] = msg.HoldingTokensBalanceIsNotEnough
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	}

	// 檢核是否有足夠的exchange token可交換
	if holdingtokennumber*holdingtokenvalue > exchangetokenvalue*exchangetokenbalance {
		ExchangeTokenResp["errmessage"] = msg.HoldingTokensBalanceIsLessThanExchangeToken
		mapResp, _ := json.Marshal(ExchangeTokenResp)
		return mapResp
	}

	fmt.Println((holdingtokennumber * holdingtokenvalue) / exchangetokenvalue)
	// 增加扣除token
	holdingTokenAccInfo.Balance += holdingtokennumber
	memberAccInfo.HoldingTokens[holdingtoken] -= holdingtokennumber
	memberAccInfo.HoldingTokens[exchangetoken] = memberAccInfo.HoldingTokens[exchangetoken] + (holdingtokennumber*holdingtokenvalue)/exchangetokenvalue
	exchangeTokenAccInfo.Balance = exchangeTokenAccInfo.Balance - (holdingtokennumber*holdingtokenvalue)/exchangetokenvalue

	//把帳號資訊重組起來 並放回去
	memberAccKeyAsBytes, _ = json.Marshal(memberAccInfo)
	t.APIstub.PutState(memberacc, memberAccKeyAsBytes)
	holdingtokenAccAsBytes, _ = json.Marshal(holdingTokenAccInfo)
	t.APIstub.PutState(holdingtoken+holdingtokenacc, holdingtokenAccAsBytes)
	exchangetokenAccAsBytes, _ = json.Marshal(exchangeTokenAccInfo)
	t.APIstub.PutState(exchangetoken+exchangetokenacc, exchangetokenAccAsBytes)

	ExchangeTokenResp["errmessage"] = ""
	ExchangeTokenResp["returncode"] = true
	mapResp, _ := json.Marshal(ExchangeTokenResp)
	return mapResp

}
