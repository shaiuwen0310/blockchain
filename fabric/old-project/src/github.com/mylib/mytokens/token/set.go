package token

import (
	"encoding/json"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	. "github.com/mylib/mytokens/data"
	"github.com/mylib/mytokens/msg"
)

type SetToken struct {
	APIstub shim.ChaincodeStubInterface
}

const (
	notEnable = 0
	isEnable  = 1
	notUse    = 2
	isZERO    = 0
)

func (s *SetToken) NewToken(tokenname string, symbol string, value uint64, total uint64, tokenaccount string, corporation string, walletid string) []byte {

	var newTokenResp = make(map[string]interface{})
	newTokenResp["tokenname"] = tokenname
	newTokenResp["returncode"] = false

	//檢查是否有這個token key:token名稱
	tokenKeyAsBytes, err := s.APIstub.GetState(tokenname)
	if err != nil {
		newTokenResp["errmessage"] = msg.FailedToGetToken + err.Error()
		mapResp, _ := json.Marshal(newTokenResp)
		return mapResp
	} else if tokenKeyAsBytes != nil {
		newTokenResp["errmessage"] = msg.ThisTokenAlreadyExists + tokenname
		mapResp, _ := json.Marshal(newTokenResp)
		return mapResp
	}

	//將token資訊組合起來 放到db中
	var tokenInfo = TokenInfo{Name: tokenname, Symbol: symbol, Value: value, State: notEnable, SupplyTotal: total, Corporation: corporation, Walletid: walletid}
	tokenAsBytes, _ := json.Marshal(tokenInfo)
	s.APIstub.PutState(tokenname, tokenAsBytes)

	//將token帳號資訊組合起來 放到db中
	var tokenAcc = TokenAccount{TokenName: tokenname, Account: tokenaccount, Balance: isZERO, State: notEnable, Walletid: walletid}
	tokenAccountAsBytes, _ := json.Marshal(tokenAcc)
	tokenAccountKey := tokenname + tokenaccount
	s.APIstub.PutState(tokenAccountKey, tokenAccountAsBytes)

	newTokenResp["errmessage"] = ""
	newTokenResp["returncode"] = true
	mapResp, _ := json.Marshal(newTokenResp)
	return mapResp

}

func (s *SetToken) StartToken(tokenname string, tokenaccount string, walletid string) []byte {

	var startTokenResp = make(map[string]interface{})
	startTokenResp["tokenname"] = tokenname
	startTokenResp["returncode"] = false

	//檢查是否有這個token
	tokenKeyAsBytes, err := s.APIstub.GetState(tokenname)
	if err != nil {
		startTokenResp["errmessage"] = msg.FailedToGetToken + err.Error()
		mapResp, _ := json.Marshal(startTokenResp)
		return mapResp
	} else if tokenKeyAsBytes == nil {
		startTokenResp["errmessage"] = msg.ThisTokenIsNotExists + tokenname
		mapResp, _ := json.Marshal(startTokenResp)
		return mapResp
	}

	//檢查是否有這個token account
	tokenAccountKeyAsBytes, err := s.APIstub.GetState(tokenname + tokenaccount)
	if err != nil {
		startTokenResp["errmessage"] = msg.FailedToGetTokenAccount + err.Error()
		mapResp, _ := json.Marshal(startTokenResp)
		return mapResp
	} else if tokenAccountKeyAsBytes == nil {
		startTokenResp["errmessage"] = msg.ThisTokenAccountIsNotExists + tokenaccount
		mapResp, _ := json.Marshal(startTokenResp)
		return mapResp
	}

	//建立用來存資料的空struct
	tokenInfo := TokenInfo{}
	tokenAccountInfo := TokenAccount{}
	//把取出來的資料放到空strict中
	json.Unmarshal(tokenKeyAsBytes, &tokenInfo)
	json.Unmarshal(tokenAccountKeyAsBytes, &tokenAccountInfo)

	//取出來的資料中所需要的值
	state := tokenAccountInfo.State     //檢核用
	balance := tokenAccountInfo.Balance //檢核用
	total := tokenInfo.SupplyTotal      //配置給帳號用

	//檢核token帳號是否尚未啟用
	if state != notEnable || balance != isZERO {
		startTokenResp["errmessage"] = msg.ParameterInTokenAccountIsWrong
		mapResp, _ := json.Marshal(startTokenResp)
		return mapResp
	}

	//設定token帳號的餘額 啟用此帳號 更新操作者
	tokenAccountInfo.Balance = total
	tokenAccountInfo.State = isEnable
	tokenAccountInfo.Walletid = walletid
	//設定啟用此token
	tokenInfo.State = isEnable

	//把更新的token資訊重組起來 並放回去
	tokenKeyAsBytes, _ = json.Marshal(tokenInfo)
	s.APIstub.PutState(tokenname, tokenKeyAsBytes)
	//把更新的token帳號資訊重組起來 並放回去
	tokenAccountKeyAsBytes, _ = json.Marshal(tokenAccountInfo)
	s.APIstub.PutState(tokenname+tokenaccount, tokenAccountKeyAsBytes)

	startTokenResp["errmessage"] = ""
	startTokenResp["returncode"] = true
	mapResp, _ := json.Marshal(startTokenResp)
	return mapResp

}

func (s *SetToken) FreezenToken(tokenname string, tokenaccount string, walletid string) []byte {

	var freezenTokenResp = make(map[string]interface{})
	freezenTokenResp["tokenname"] = tokenname
	freezenTokenResp["returncode"] = false

	//檢查是否有這個token
	tokenKeyAsBytes, err := s.APIstub.GetState(tokenname)
	if err != nil {
		freezenTokenResp["errmessage"] = msg.FailedToGetToken + err.Error()
		mapResp, _ := json.Marshal(freezenTokenResp)
		return mapResp
	} else if tokenKeyAsBytes == nil {
		freezenTokenResp["errmessage"] = msg.ThisTokenIsNotExists + tokenname
		mapResp, _ := json.Marshal(freezenTokenResp)
		return mapResp
	}

	//檢查是否有這個token account
	tokenAccountKeyAsBytes, err := s.APIstub.GetState(tokenname + tokenaccount)
	if err != nil {
		freezenTokenResp["errmessage"] = msg.FailedToGetTokenAccount + err.Error()
		mapResp, _ := json.Marshal(freezenTokenResp)
		return mapResp
	} else if tokenAccountKeyAsBytes == nil {
		freezenTokenResp["errmessage"] = msg.ThisTokenAccountIsNotExists + tokenaccount
		mapResp, _ := json.Marshal(freezenTokenResp)
		return mapResp
	}

	//建立用來存資料的空struct
	tokenInfo := TokenInfo{}
	tokenAccountInfo := TokenAccount{}
	//把取出來的資料放到空strict中
	json.Unmarshal(tokenKeyAsBytes, &tokenInfo)
	json.Unmarshal(tokenAccountKeyAsBytes, &tokenAccountInfo)

	//取出來的資料中所需要的值
	tokenSTS := tokenInfo.State           //檢核用
	tokenAccSTS := tokenAccountInfo.State //檢核用

	//檢核token帳號是否已凍結
	if tokenSTS == notUse || tokenAccSTS == notUse {
		freezenTokenResp["errmessage"] = msg.ThisTokenIsAlreadyFreezen
		mapResp, _ := json.Marshal(freezenTokenResp)
		return mapResp
	}

	//設定token帳號 動結帳號 更新操作者
	tokenAccountInfo.State = notUse
	tokenAccountInfo.Walletid = walletid
	//設定凍結此token
	tokenInfo.State = notUse

	//把更新的token資訊重組起來 並放回去
	tokenKeyAsBytes, _ = json.Marshal(tokenInfo)
	s.APIstub.PutState(tokenname, tokenKeyAsBytes)
	//把更新的token帳號資訊重組起來 並放回去
	tokenAccountKeyAsBytes, _ = json.Marshal(tokenAccountInfo)
	s.APIstub.PutState(tokenname+tokenaccount, tokenAccountKeyAsBytes)

	freezenTokenResp["errmessage"] = ""
	freezenTokenResp["returncode"] = true
	mapResp, _ := json.Marshal(freezenTokenResp)
	return mapResp

}

func (s *SetToken) DeleteToken(tokenname string, tokenaccount string, walletid string) []byte {

	var deleteTokenResp = make(map[string]interface{})
	deleteTokenResp["tokenname"] = tokenname
	deleteTokenResp["returncode"] = false

	//檢查是否有這個token
	tokenKeyAsBytes, err := s.APIstub.GetState(tokenname)
	if err != nil {
		deleteTokenResp["errmessage"] = msg.FailedToGetToken + err.Error()
		mapResp, _ := json.Marshal(deleteTokenResp)
		return mapResp
	} else if tokenKeyAsBytes == nil {
		deleteTokenResp["errmessage"] = msg.ThisTokenIsNotExists + tokenname
		mapResp, _ := json.Marshal(deleteTokenResp)
		return mapResp
	}

	//檢查是否有這個token account
	tokenAccountKeyAsBytes, err := s.APIstub.GetState(tokenname + tokenaccount)
	if err != nil {
		deleteTokenResp["errmessage"] = msg.FailedToGetTokenAccount + err.Error()
		mapResp, _ := json.Marshal(deleteTokenResp)
		return mapResp
	} else if tokenAccountKeyAsBytes == nil {
		deleteTokenResp["errmessage"] = msg.ThisTokenAccountIsNotExists + tokenaccount
		mapResp, _ := json.Marshal(deleteTokenResp)
		return mapResp
	}

	err = s.APIstub.DelState(tokenname)
	errs := s.APIstub.DelState(tokenname + tokenaccount)
	if err == nil && errs == nil {
		deleteTokenResp["errmessage"] = ""
		deleteTokenResp["returncode"] = true
		mapResp, _ := json.Marshal(deleteTokenResp)
		return mapResp
	} else {
		deleteTokenResp["errmessage"] = msg.FailToDeleteTheToken
		mapResp, _ := json.Marshal(deleteTokenResp)
		return mapResp
	}

}
