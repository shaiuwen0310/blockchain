import { Component, OnInit } from '@angular/core';

import { freeApiService }    from '../services/freeapi.service';
import { CoinbaseAndMbrTxn, PostTxnREQ, CoinbaseAndMbrTxnResp, InterMemberTxn, InterMemberTxnResp, TokenExchangeTxn, TokenExchangeTxnResp }    from '../classes/txn';

@Component({
  selector: 'app-paging3',
  templateUrl: './paging3.component.html',
  styleUrls: ['./paging3.component.css']
})
export class Paging3Component implements OnInit {

  constructor(private _freeApiService: freeApiService) { }

  ngOnInit() {
  }

  //畫面輸入的欄位
  inputTokenname: string;
  inputTokenaccount: string;
  inputMemberaccount: string;
  inputCounts: number;
  inputWalletid: string;
  inputWho: string;
  //收到後端的回覆
  objTxnResp:CoinbaseAndMbrTxnResp;
  //顯示在頁面上
  CoinbaseAndMbrR: string;
  coinbaseAndMbrTxnFunc(){

    this.CoinbaseAndMbrR = "";

    var txnwithcoinbase = new PostTxnREQ();
    var values = new CoinbaseAndMbrTxn();

    txnwithcoinbase.userName = this.inputWalletid;
    txnwithcoinbase.chaincodeFunction = 'transfers';

    values.tokenname = this.inputTokenname;
    values.tokenaccount = this.inputTokenaccount;
    values.memberaccount = this.inputMemberaccount;
    values.counts = this.inputCounts;
    values.choose = this.inputWho;
    values.walletid = this.inputWalletid;

    txnwithcoinbase.values = values;

    this._freeApiService.invokeTxnPost(txnwithcoinbase).subscribe(
      data=>{
        this.objTxnResp = data;
        if (this.objTxnResp.returncode) {
          this.CoinbaseAndMbrR = "Successful transfer token!";
        } else {
          this.CoinbaseAndMbrR = "error message: " +  this.objTxnResp.errmessage;
        }
        this.inputTokenname = null;
        this.inputTokenaccount = null;
        this.inputMemberaccount = null;
        this.inputCounts = null;
        this.inputWalletid = null;
        this.inputWho = null;
      }
    );
  }

  //畫面輸入的欄位
  inputTokennameINT: string;
  memberFromaccountsINT: string;
  memberToaccountsINT: string;
  inputWalletidINT: string;
  inputCountssINT: number;
  //收到後端的回覆
  objTxnRespINT:InterMemberTxnResp;
  //顯示在頁面上
  InterMemberR: string;
  InterMemberTxnFunc(){

    this.InterMemberR = "";

    var txnwithcoinbase = new PostTxnREQ();
    var values = new InterMemberTxn();

    txnwithcoinbase.userName = this.inputWalletidINT;
    txnwithcoinbase.chaincodeFunction = 'transferfroms';

    values.tokenname = this.inputTokennameINT;
    values.memberfromaccount = this.memberFromaccountsINT;
    values.membertoaccount = this.memberToaccountsINT;
    values.counts = this.inputCountssINT;
    values.walletid = this.inputWalletidINT;

    txnwithcoinbase.values = values;

    this._freeApiService.invokeTxnPost(txnwithcoinbase).subscribe(
      data=>{
        this.objTxnRespINT = data;
        if (this.objTxnRespINT.returncode) {
          this.InterMemberR = "Successful transfer token!";
        } else {
          this.InterMemberR = "error message: " +  this.objTxnRespINT.errmessage;
        }
        this.inputTokennameINT = null;
        this.memberFromaccountsINT = null;
        this.memberToaccountsINT = null;
        this.inputCountssINT = null;
        this.inputWalletidINT = null;
      }
    );
  }

  //畫面輸入的欄位

  inputmemberacc: string;
  inputholdingtoken: string;
  inputholdingtokenacc: string;
  inputholdingtokennumber: number;
  inputexchangetoken: string;
  inputexchangetokenacc: string;
  inputwalletid: string;
  //收到後端的回覆
  objTxnRespEx:TokenExchangeTxnResp;
  //顯示在頁面上
  TokenExchangeR: string;
  TokenExchangeTxnFunc(){

    this.TokenExchangeR = "";

    var tokenexchange = new PostTxnREQ();
    var values = new TokenExchangeTxn();

    tokenexchange.userName = this.inputwalletid;
    tokenexchange.chaincodeFunction = 'exchangetoken';

    values.holdingtoken = this.inputholdingtoken;
    values.holdingtokenacc = this.inputholdingtokenacc;
    values.holdingtokennumber = this.inputholdingtokennumber;
    values.exchangetoken = this.inputexchangetoken;
    values.exchangetokenacc = this.inputexchangetokenacc;
    values.walletid = this.inputwalletid;
    values.memberacc = this.inputmemberacc;

    tokenexchange.values = values;

    this._freeApiService.invokeTxnPost(tokenexchange).subscribe(
      data=>{
        this.objTxnRespEx = data;
        if (this.objTxnRespEx.returncode) {
          this.TokenExchangeR = "Successful transfer token!";
        } else {
          this.TokenExchangeR = "error message: " +  this.objTxnRespEx.errmessage;
        }
        this.inputholdingtoken = null;
        this.inputholdingtokenacc = null;
        this.inputholdingtokennumber = null;
        this.inputexchangetoken = null;
        this.inputexchangetokenacc = null;
        this.inputwalletid = null;
        this.inputmemberacc = null;
      }
    );
  }


}
