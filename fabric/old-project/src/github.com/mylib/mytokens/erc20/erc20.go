package erc20

import (
	"encoding/json"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	. "github.com/mylib/mytokens/data"
	"github.com/mylib/mytokens/msg"
)

type Erc20 struct {
	APIstub shim.ChaincodeStubInterface
}

const (
	notEnable = 0
	isEnable  = 1
	notUse    = 2
	isZERO    = 0
)

func (e *Erc20) TotalSupply(tokenname string) (uint64, string, bool) {

	//檢查是否有這個token
	tokenKeyAsBytes, err := e.APIstub.GetState(tokenname)
	if err != nil {
		return 0, msg.FailedToGetToken + err.Error(), false
	} else if tokenKeyAsBytes == nil {
		return 0, msg.ThisTokenIsNotExists + tokenname, false
	}

	//建立用來存資料的空struct
	tokenInfo := TokenInfo{}
	//把取出來的資料放到空strict中
	json.Unmarshal(tokenKeyAsBytes, &tokenInfo)

	//存取token的餘額 轉成json格式返回前端
	return tokenInfo.SupplyTotal, "", true
}

/*
同意每次交易 A會員轉給B會員的token價值上限
return 錯誤訊息, 失敗成功
*/
func (e *Erc20) Approve(mycaaount string, hisaccount string, value uint64, walletid string) (string, bool) {

	//檢核是否有轉出會員帳戶存在
	myAccountAsBytes, err := e.APIstub.GetState(mycaaount)
	if err != nil {
		return msg.FailedToGetMemberAccount + err.Error(), false
	} else if myAccountAsBytes == nil {
		return msg.ThisMemberAccountIsNotExists + mycaaount, false
	}

	//檢核是否有轉入會員帳戶存在
	hisAccountAsBytes, err := e.APIstub.GetState(hisaccount)
	if err != nil {
		return msg.FailedToGetMemberAccount + err.Error(), false
	} else if hisAccountAsBytes == nil {
		return msg.ThisMemberAccountIsNotExists + hisaccount, false
	}

	//建立用來存資料的空struct
	myAccountInfo := MemberAccount{}
	hisAccountInfo := MemberAccount{}

	//把取出來的資料放到空strict中
	json.Unmarshal(myAccountAsBytes, &myAccountInfo)
	json.Unmarshal(hisAccountAsBytes, &hisAccountInfo)

	//取出來的資料中所需要的值
	myAccountState := myAccountInfo.State
	hisAccountState := hisAccountInfo.State

	//會員轉出帳號狀態應為啟動 會員轉入帳號狀態應為啟動
	if myAccountState != isEnable || hisAccountState != isEnable {
		return msg.MemberAccountIsNotEnable, false
	}

	//檢核價值不小於零
	if value < 0 {
		return msg.TheValueISInvalid, false
	}

	//將同意資訊組合起來 放到db中
	var approvevalue = ApproveValue{MyAccount: mycaaount, HisAccount: hisaccount, ApproveOf: value, WalletId: walletid}
	approveValueAsBytes, _ := json.Marshal(approvevalue)
	e.APIstub.PutState(mycaaount+"-"+hisaccount, approveValueAsBytes)

	return "", true
}

/*
查詢每次A帳號可以轉帳多少價值給B帳號
return 價值, 錯誤訊息, 失敗成功
*/
func (e *Erc20) Allowance(mycaaount string, hisaccount string) (uint64, string, bool) {

	//檢核是否有轉出會員帳戶存在
	myAccountAsBytes, err := e.APIstub.GetState(mycaaount)
	if err != nil {
		return 0, msg.FailedToGetMemberAccount + err.Error(), false
	} else if myAccountAsBytes == nil {
		return 0, msg.ThisMemberAccountIsNotExists + mycaaount, false
	}

	//檢核是否有轉入會員帳戶存在
	hisAccountAsBytes, err := e.APIstub.GetState(hisaccount)
	if err != nil {
		return 0, msg.FailedToGetMemberAccount + err.Error(), false
	} else if hisAccountAsBytes == nil {
		return 0, msg.ThisMemberAccountIsNotExists + hisaccount, false
	}

	//檢核是否有這個同意資訊
	ApproveValueAsBytes, err := e.APIstub.GetState(mycaaount + "-" + hisaccount)
	if err != nil {
		return 0, msg.FailedToGetTheApproval + err.Error(), false
	} else if ApproveValueAsBytes == nil {
		return 0, msg.ThisApprovalIsNotExists + mycaaount, false
	}

	//建立用來存資料的空struct
	myApproveInfo := ApproveValue{}
	//把取出來的資料放到空struct中
	json.Unmarshal(ApproveValueAsBytes, &myApproveInfo)

	//取出來的資料中所需要的值
	myapproveacc := myApproveInfo.HisAccount
	myapprovevalue := myApproveInfo.ApproveOf

	//檢核其他帳號是否正確
	if hisaccount != myapproveacc {
		return 0, msg.ThisIsNotYourApprovalAccount + err.Error(), false
	}

	return myapprovevalue, "", true
}

/*
查看帳戶餘額
return 價值, 錯誤訊息, 失敗成功
*/
func (e *Erc20) BalanceOf(memberaccount string) (map[string]uint64, string, bool) {

	//檢核是否有會員帳戶存在
	memberAccountAsBytes, err := e.APIstub.GetState(memberaccount)
	if err != nil {
		return nil, msg.FailedToGetMemberAccount + err.Error(), false
	} else if memberAccountAsBytes == nil {
		return nil, msg.ThisMemberAccountIsNotExists + memberaccount, false
	}

	//建立用來存資料的空struct
	memberAccountInfo := MemberAccount{}

	//把取出來的資料放到空struct中
	json.Unmarshal(memberAccountAsBytes, &memberAccountInfo)

	//存取會員的token
	holdingtokens := memberAccountInfo.HoldingTokens

	return holdingtokens, "", true
}

/*
token帳戶與會員帳戶之間互相轉帳
return 錯誤訊息, 成功失敗
*/
func (e *Erc20) Transfer(tokenname string, tokenaccount string, memberaccount string, counts uint64, walletid string, choose string) (string, bool) {

	//檢核是否有此token帳號存在
	tokenAccountAsBytes, err := e.APIstub.GetState(tokenname + tokenaccount)
	if err != nil {
		return msg.FailedToGetTokenAccount + err.Error(), false
	} else if tokenAccountAsBytes == nil {
		return msg.ThisTokenAccountIsNotExists + tokenaccount, false
	}

	//檢核是否有此會員帳戶存在
	memberAccountAsBytes, err := e.APIstub.GetState(memberaccount)
	if err != nil {
		return msg.FailedToGetMemberAccount + err.Error(), false
	} else if memberAccountAsBytes == nil {
		return msg.ThisMemberAccountIsNotExists + memberaccount, false
	}

	//建立用來存資料的空struct
	tokenAccountInfo := TokenAccount{}
	memberAccountInfo := MemberAccount{}

	//把取出來的資料放到空strict中
	json.Unmarshal(tokenAccountAsBytes, &tokenAccountInfo)
	json.Unmarshal(memberAccountAsBytes, &memberAccountInfo)

	//取出來的資料中所需要的值
	tokenAccount := tokenAccountInfo.Account
	tokenAccountState := tokenAccountInfo.State
	tokenAccountBalance := tokenAccountInfo.Balance
	memberAccount := memberAccountInfo.Account
	memberAccountState := memberAccountInfo.State
	memberAccountBlalnce := memberAccountInfo.HoldingTokens[tokenname]

	//操作者應該為token發放單位 故token帳號及會員帳號操作者皆相同
	tokenAccountInfo.Walletid = walletid
	memberAccountInfo.Walletid = walletid

	//檢核token帳號狀態應為啟動 會員帳號狀態應為啟動
	if tokenAccountState != isEnable || memberAccountState != isEnable {
		return msg.OneOfAccountIsNotEnable, false
	}

	//從token帳號轉帳給會員帳號
	if choose == tokenAccount && tokenAccountBalance >= counts {
		//增加member帳號中的餘額
		memberAccountInfo.HoldingTokens[tokenname] += counts
		//扣除token帳號中的餘額
		tokenAccountInfo.Balance -= counts

		//將token帳號及member資訊組合起來 放到db中
		tokenAccountAsBytes, _ = json.Marshal(tokenAccountInfo)
		memberAccountAsBytes, _ = json.Marshal(memberAccountInfo)
		e.APIstub.PutState(tokenname+tokenaccount, tokenAccountAsBytes)
		e.APIstub.PutState(memberaccount, memberAccountAsBytes)
		return "", true
	}

	//從會員帳號轉帳給token帳號
	if choose == memberAccount && memberAccountBlalnce >= counts {
		//增加token帳號中的餘額
		tokenAccountInfo.Balance += counts
		//扣除member帳號中的餘額
		memberAccountInfo.HoldingTokens[tokenname] -= counts

		//將token帳號及member資訊組合起來 放到db中
		tokenAccountAsBytes, _ = json.Marshal(tokenAccountInfo)
		memberAccountAsBytes, _ = json.Marshal(memberAccountInfo)
		e.APIstub.PutState(tokenname+tokenaccount, tokenAccountAsBytes)
		e.APIstub.PutState(memberaccount, memberAccountAsBytes)
		return "", true
	}
	return "from account doesn't match choose or counts is more than token's balance", false
}

/*
從轉出會員帳號轉帳到軟入會員帳號
return 錯誤訊息, 失敗成功
*/
func (e *Erc20) TransferFrom(tokenname string, memberfromaccount string, membertoaccount string, counts uint64, walletid string) (string, bool) {

	//檢核是否有此token存在
	tokenAsBytes, err := e.APIstub.GetState(tokenname)
	if err != nil {
		return msg.FailedToGetToken + err.Error(), false
	} else if tokenAsBytes == nil {
		return msg.ThisTokenIsNotExists + tokenname, false
	}

	//檢核是否有轉出會員帳戶存在
	memberFromAccountAsBytes, err := e.APIstub.GetState(memberfromaccount)
	if err != nil {
		return msg.FailedToGetMemberAccount + err.Error(), false
	} else if memberFromAccountAsBytes == nil {
		return msg.ThisMemberAccountIsNotExists + memberfromaccount, false
	}

	//檢核是否有轉入會員帳戶存在
	memberToAccountAsBytes, err := e.APIstub.GetState(membertoaccount)
	if err != nil {
		return msg.FailedToGetMemberAccount + err.Error(), false
	} else if memberToAccountAsBytes == nil {
		return msg.ThisMemberAccountIsNotExists + membertoaccount, false
	}

	allowvalue, errmsg, isOk := e.Allowance(memberfromaccount, membertoaccount)
	if !isOk {
		return msg.FailedAllowance + membertoaccount + ": " + errmsg, false
	}

	//建立用來存資料的空struct
	tokenInfo := TokenInfo{}
	memberFromAccountInfo := MemberAccount{}
	memberToAccountInfo := MemberAccount{}

	//把取出來的資料放到空strict中
	json.Unmarshal(tokenAsBytes, &tokenInfo)
	json.Unmarshal(memberFromAccountAsBytes, &memberFromAccountInfo)
	json.Unmarshal(memberToAccountAsBytes, &memberToAccountInfo)

	//取出來的資料中所需要的值
	tokenState := tokenInfo.State
	tokenvalue := tokenInfo.Value
	memberFromAccountbalance := memberFromAccountInfo.HoldingTokens[tokenname]
	memberFromAccountState := memberFromAccountInfo.State
	memberToAccountState := memberToAccountInfo.State

	//檢核token狀態應為啟動 會員轉出帳號狀態應為啟動 會員轉入帳號狀態應為啟動 會員轉出帳號的餘額應大於點數 此檢核包含會員轉出帳號沒有該點數的判斷
	if tokenState != isEnable || memberFromAccountState != isEnable || memberToAccountState != isEnable || memberFromAccountbalance < counts {
		return msg.FailedToTransformTokens, false
	}

	//檢核from轉給to的token價值是否超過
	if (tokenvalue * counts) > allowvalue {
		return msg.YourCountsAreTooMany, false
	}

	//增加會員轉入帳號中的餘額
	memberToAccountInfo.HoldingTokens[tokenname] += counts

	//減少會員轉出帳號中的餘額
	memberFromAccountInfo.HoldingTokens[tokenname] -= counts

	//操作者應該為轉出帳號會員 故會員轉出帳號及會員轉入帳號操作者皆相同
	memberFromAccountInfo.Walletid = walletid
	memberToAccountInfo.Walletid = walletid

	//將會員轉出帳號及會員轉入帳號的資訊組合起來 放到db中
	memberFromAccountAsBytes, _ = json.Marshal(memberFromAccountInfo)
	memberToAccountAsBytes, _ = json.Marshal(memberToAccountInfo)
	e.APIstub.PutState(memberfromaccount, memberFromAccountAsBytes)
	e.APIstub.PutState(membertoaccount, memberToAccountAsBytes)

	return "", true
}
