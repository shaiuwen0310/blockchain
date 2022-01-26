package account

import (
	"encoding/json"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	. "github.com/mylib/mytokens/data"
	"github.com/mylib/mytokens/erc20"
	"github.com/mylib/mytokens/msg"
)

type SetAccount struct {
	APIstub shim.ChaincodeStubInterface
}

const (
	notEnable = 0
	isEnable  = 1
	notUse    = 2
	isZERO    = 0
)

func (s *SetAccount) NewMemberAccount(membername string, account string, walletid string) []byte {

	var newMemberResp = make(map[string]interface{})
	newMemberResp["account"] = account
	newMemberResp["returncode"] = false

	//檢核帳號是否已存在 key:會員帳號
	memberAccountKeyAsBytes, err := s.APIstub.GetState(account)
	if err != nil {
		newMemberResp["errmessage"] = msg.FailedToGetMemberAccount + err.Error()
		mapResp, _ := json.Marshal(newMemberResp)
		return mapResp
	} else if memberAccountKeyAsBytes != nil {
		newMemberResp["errmessage"] = msg.ThisMemberAccountIsAlreadyExists + account
		mapResp, _ := json.Marshal(newMemberResp)
		return mapResp
	}

	//將member account資訊組合起來 放到db中
	var memberaccount = MemberAccount{MemberName: membername, Account: account, State: notEnable, Walletid: walletid, HoldingTokens: make(map[string]uint64)}
	memberAccountAsBytes, _ := json.Marshal(memberaccount)
	s.APIstub.PutState(account, memberAccountAsBytes)

	newMemberResp["errmessage"] = ""
	newMemberResp["returncode"] = true
	mapResp, _ := json.Marshal(newMemberResp)
	return mapResp
}

func (s *SetAccount) StartupMemberAccount(account string, walletid string) []byte {

	var StartMemberResp = make(map[string]interface{})
	StartMemberResp["account"] = account
	StartMemberResp["returncode"] = false

	//檢查這個會員帳號是否存在
	memberAccountAsBytes, err := s.APIstub.GetState(account)
	if err != nil {
		StartMemberResp["errmessage"] = msg.FailedToGetMemberAccount + err.Error()
		mapResp, _ := json.Marshal(StartMemberResp)
		return mapResp
	} else if memberAccountAsBytes == nil {
		StartMemberResp["errmessage"] = msg.ThisMemberAccountIsNotExists + account
		mapResp, _ := json.Marshal(StartMemberResp)
		return mapResp
	}

	//建立用來存資料的空struct
	memberAccountInfo := MemberAccount{}
	//把取出來的會員帳號資訊放到空strict中
	json.Unmarshal(memberAccountAsBytes, &memberAccountInfo)

	//檢核會員帳號是否尚未啟用
	state := memberAccountInfo.State
	if state != notEnable {
		StartMemberResp["errmessage"] = msg.ThisMemberAccountIsNotEnable + account
		mapMember, _ := json.Marshal(StartMemberResp)
		return mapMember
	}

	//設定啟用此會員帳號 更新操作者
	memberAccountInfo.State = isEnable
	memberAccountInfo.Walletid = walletid

	//把更新的會員帳號資訊重組起來 並放回去
	memberAccountAsBytes, _ = json.Marshal(memberAccountInfo)
	s.APIstub.PutState(account, memberAccountAsBytes)

	StartMemberResp["errmessage"] = ""
	StartMemberResp["returncode"] = true
	mapResp, _ := json.Marshal(StartMemberResp)
	return mapResp

}

func (s *SetAccount) MemberApprove(myaccount string, hisaccount string, value uint64, walletid string) []byte {

	var approveMemberResp = make(map[string]interface{})
	approveMemberResp["myaccount"] = myaccount
	approveMemberResp["hisaccount"] = hisaccount
	approveMemberResp["value"] = value

	e := erc20.Erc20{
		s.APIstub,
	}
	errmsg, isOk := e.Approve(myaccount, hisaccount, value, walletid)
	if isOk {

		approveMemberResp["errmessage"] = ""
		approveMemberResp["returncode"] = true
	} else {
		approveMemberResp["errmessage"] = errmsg
		approveMemberResp["returncode"] = false
	}

	mapResp, _ := json.Marshal(approveMemberResp)
	return mapResp

}

func (s *SetAccount) FreezenMember(account string, walletid string) []byte {

	var FreezenMemberResp = make(map[string]interface{})
	FreezenMemberResp["account"] = account
	FreezenMemberResp["returncode"] = false

	memberAccountAsBytes, err := s.APIstub.GetState(account)
	if err != nil {
		FreezenMemberResp["errmessage"] = msg.FailedToGetMemberAccount + err.Error()
		mapResp, _ := json.Marshal(FreezenMemberResp)
		return mapResp
	} else if memberAccountAsBytes == nil {
		FreezenMemberResp["errmessage"] = msg.ThisMemberAccountIsNotExists + account
		mapResp, _ := json.Marshal(FreezenMemberResp)
		return mapResp
	}

	//建立用來存資料的空struct
	memberAccountInfo := MemberAccount{}
	//把取出來的會員帳號資訊放到空strict中
	json.Unmarshal(memberAccountAsBytes, &memberAccountInfo)

	//取出來的資料中所需要的值
	memberSTS := memberAccountInfo.State //檢核用

	//檢核member帳號是否已凍結
	if memberSTS == notUse {
		FreezenMemberResp["errmessage"] = msg.ThisMemberIsAlreadyFreezen
		mapResp, _ := json.Marshal(FreezenMemberResp)
		return mapResp
	}

	//設定凍結此member 更新操作者
	memberAccountInfo.State = notUse
	memberAccountInfo.Walletid = walletid

	//把更新的會員帳號資訊重組起來 並放回去
	memberAccountAsBytes, _ = json.Marshal(memberAccountInfo)
	s.APIstub.PutState(account, memberAccountAsBytes)

	FreezenMemberResp["errmessage"] = ""
	FreezenMemberResp["returncode"] = true
	mapResp, _ := json.Marshal(FreezenMemberResp)
	return mapResp

}
