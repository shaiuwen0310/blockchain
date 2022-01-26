package main

import (
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
	"github.com/mylib/mytokens/account"
	"github.com/mylib/mytokens/msg"
	"github.com/mylib/mytokens/token"
	"github.com/mylib/mytokens/transfer"
)

type SmartContract struct {
}

func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	function, args := APIstub.GetFunctionAndParameters()

	if function == "newtoken" {
		return s.newToken(APIstub, args)
	} else if function == "activatetoken" {
		return s.ActivateToken(APIstub, args)
	} else if function == "freezenatoken" {
		return s.FreezenAToken(APIstub, args)
	} else if function == "deleteatoken" {
		return s.DeleteAToken(APIstub, args)
	} else if function == "informationoftoken" {
		return s.InformationOfToken(APIstub, args)
	} else if function == "supplytotaloftoken" {
		return s.SupplyTotalOfToken(APIstub, args)
	} else if function == "historyoftokenaccount" {
		return s.HistoryOfTokenAccount(APIstub, args)
	} else if function == "newamemberaccount" {
		return s.NewAMemberAccount(APIstub, args)
	} else if function == "activatememberaccount" {
		return s.ActivateMemberAccount(APIstub, args)
	} else if function == "memberapprove" {
		return s.MemberApprove(APIstub, args)
	} else if function == "freezenmember" {
		return s.FreezenMember(APIstub, args)
	} else if function == "memberallowance" {
		return s.MemberAllowance(APIstub, args)
	} else if function == "memberbalanceof" {
		return s.MemberBalanceOf(APIstub, args)
	} else if function == "gethistoryofaccount" {
		return s.GetHistoryOfAccount(APIstub, args)
	} else if function == "transfers" {
		return s.Transfers(APIstub, args)
	} else if function == "transferfroms" {
		return s.TransferFroms(APIstub, args)
	} else if function == "exchangetoken" {
		return s.ExchangeToken(APIstub, args)
	}
	return shim.Error("Invalid Smart Contract function name. " + function)
}

func (s *SmartContract) newToken(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) != 7 {
		return shim.Error(msg.IncorrectNumberOfArguments + "7")
	}

	//輸入參數
	tokenname := args[0]
	symbol := args[1]
	value, _ := strconv.ParseUint(args[2], 10, 64)
	total, _ := strconv.ParseUint(args[3], 10, 64)
	tokenaccount := args[4]
	corporation := args[5]
	walletid := args[6]

	t := token.SetToken{
		APIstub,
	}
	mapToken := t.NewToken(tokenname, symbol, value, total, tokenaccount, corporation, walletid)
	return shim.Success(mapToken)
}

func (s *SmartContract) ActivateToken(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 3 {
		return shim.Error(msg.IncorrectNumberOfArguments + "3")
	}

	//輸入參數
	tokenname := args[0]
	tokenaccount := args[1]
	walletid := args[2]

	t := token.SetToken{
		APIstub,
	}
	mapToken := t.StartToken(tokenname, tokenaccount, walletid)
	return shim.Success(mapToken)

}

func (s *SmartContract) FreezenAToken(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 3 {
		return shim.Error(msg.IncorrectNumberOfArguments + "3")
	}

	//輸入參數
	tokenname := args[0]
	tokenaccount := args[1]
	walletid := args[2]

	t := token.SetToken{
		APIstub,
	}
	mapToken := t.FreezenToken(tokenname, tokenaccount, walletid)
	return shim.Success(mapToken)

}

func (s *SmartContract) DeleteAToken(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 3 {
		return shim.Error(msg.IncorrectNumberOfArguments + "3")
	}

	//輸入參數
	tokenname := args[0]
	tokenaccount := args[1]
	walletid := args[2]

	t := token.SetToken{
		APIstub,
	}
	mapToken := t.DeleteToken(tokenname, tokenaccount, walletid)
	return shim.Success(mapToken)

}

func (s *SmartContract) InformationOfToken(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error(msg.IncorrectNumberOfArguments + "1")
	}

	//輸入參數
	tokenname := args[0]

	t := token.GetToken{
		APIstub,
	}
	mapToken := t.GetTokenInfo(tokenname)
	return shim.Success(mapToken)
}

func (s *SmartContract) SupplyTotalOfToken(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error(msg.IncorrectNumberOfArguments + "1")
	}

	//輸入參數
	tokenname := args[0]

	t := token.GetToken{
		APIstub,
	}
	mapToken := t.GetTokenSupplyTotal(tokenname)
	return shim.Success(mapToken)

}

func (s *SmartContract) HistoryOfTokenAccount(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error(msg.IncorrectNumberOfArguments + "2")
	}

	//輸入參數
	tokenname := args[0]
	tokenaccount := args[1]

	t := token.GetToken{
		APIstub,
	}
	mapToken := t.GetHistoryOfTokenAccount(tokenname, tokenaccount)
	return shim.Success(mapToken)

}

func (s *SmartContract) NewAMemberAccount(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 3 {
		return shim.Error(msg.IncorrectNumberOfArguments + "3")
	}

	//輸入參數
	membername := args[0]
	memberaccount := args[1]
	walletid := args[2]

	a := account.SetAccount{
		APIstub,
	}
	mapAccount := a.NewMemberAccount(membername, memberaccount, walletid)
	return shim.Success(mapAccount)

}

func (s *SmartContract) ActivateMemberAccount(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error(msg.IncorrectNumberOfArguments + "2")
	}

	//輸入參數
	memberaccount := args[0]
	walletid := args[1]

	a := account.SetAccount{
		APIstub,
	}
	mapAccount := a.StartupMemberAccount(memberaccount, walletid)
	return shim.Success(mapAccount)

}

func (s *SmartContract) MemberApprove(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 4 {
		return shim.Error(msg.IncorrectNumberOfArguments + "4")
	}

	//輸入參數
	myaccount := args[0]
	hisaccount := args[1]
	value, _ := strconv.ParseUint(args[2], 10, 64)
	walletid := args[3]

	a := account.SetAccount{
		APIstub,
	}
	mapAccount := a.MemberApprove(myaccount, hisaccount, value, walletid)
	return shim.Success(mapAccount)

}

func (s *SmartContract) FreezenMember(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error(msg.IncorrectNumberOfArguments + "2")
	}

	//輸入參數
	memberaccount := args[0]
	walletid := args[1]

	a := account.SetAccount{
		APIstub,
	}
	mapAccount := a.FreezenMember(memberaccount, walletid)
	return shim.Success(mapAccount)

}

func (s *SmartContract) MemberAllowance(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error(msg.IncorrectNumberOfArguments + "2")
	}

	//輸入參數
	myaccount := args[0]
	hisaccount := args[1]

	a := account.GetAccount{
		APIstub,
	}
	mapAccount := a.MemberAllowance(myaccount, hisaccount)
	return shim.Success(mapAccount)

}

func (s *SmartContract) MemberBalanceOf(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error(msg.IncorrectNumberOfArguments + "1")
	}

	//輸入參數
	memberaccount := args[0]

	a := account.GetAccount{
		APIstub,
	}
	mapAccount := a.MemberBalanceOf(memberaccount)
	return shim.Success(mapAccount)

}

func (s *SmartContract) GetHistoryOfAccount(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error(msg.IncorrectNumberOfArguments + "1")
	}

	//輸入參數
	memberaccount := args[0]

	a := account.GetAccount{
		APIstub,
	}
	mapAccount := a.GetHistoryOfAccount(memberaccount)
	return shim.Success(mapAccount)

}

func (s *SmartContract) Transfers(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 6 {
		return shim.Error(msg.IncorrectNumberOfArguments + "6")
	}

	//輸入參數
	tokenname := args[0]
	tokenaccount := args[1]
	memberaccount := args[2]
	counts, _ := strconv.ParseUint(args[3], 10, 64)
	walletid := args[4]
	choose := args[5]

	t := transfer.Txn{
		APIstub,
	}
	mapTransfer := t.Transfers(tokenname, tokenaccount, memberaccount, counts, walletid, choose)
	return shim.Success(mapTransfer)

}

func (s *SmartContract) TransferFroms(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 5 {
		return shim.Error(msg.IncorrectNumberOfArguments + "5")
	}

	//輸入參數
	tokenname := args[0]
	memberfromaccount := args[1]
	membertoaccount := args[2]
	counts, _ := strconv.ParseUint(args[3], 10, 64)
	walletid := args[4]

	t := transfer.Txn{
		APIstub,
	}
	mapTransferFrom := t.TransferFroms(tokenname, memberfromaccount, membertoaccount, counts, walletid)
	return shim.Success(mapTransferFrom)

}

func (s *SmartContract) ExchangeToken(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 7 {
		return shim.Error(msg.IncorrectNumberOfArguments + "7")
	}

	//輸入參數
	memberacc := args[0]
	holdingtoken := args[1]
	holdingtokenacc := args[2]
	holdingtokennumber, _ := strconv.ParseUint(args[3], 10, 64)
	exchangetoken := args[4]
	exchangetokenacc := args[5]
	walletid := args[6]

	t := transfer.Txn{
		APIstub,
	}
	mapExchangeToken := t.ExchangeToken(memberacc, holdingtoken, holdingtokenacc, holdingtokennumber, exchangetoken, exchangetokenacc, walletid)
	return shim.Success(mapExchangeToken)

}

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
