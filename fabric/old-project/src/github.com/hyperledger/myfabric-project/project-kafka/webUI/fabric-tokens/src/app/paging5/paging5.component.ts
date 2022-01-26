import { Component, OnInit } from '@angular/core';
import { freeApiService }    from '../services/freeapi.service';
import { PostMemberREQ, MemberAllowance, AllowanceMemberResp, MemberBalanceOf, MemberBalanceOfResp, MemberAccInfo, historyMemberAccResp, historyMemberBalanceOfResp }    from '../classes/member';
import { JsonPipe } from '@angular/common';

@Component({
  selector: 'app-paging5',
  templateUrl: './paging5.component.html',
  styleUrls: ['./paging5.component.css']
})
export class Paging5Component implements OnInit {

  constructor(private _freeApiService: freeApiService) { }

  ngOnInit() {
  }

  //畫面輸入的欄位
  inputMyaccount: string;
  inputHisaccount: string;
  inputEnterid: string;
  //收到後端的回覆
  MemberAllowanceResp:AllowanceMemberResp;
  //顯示在頁面上
  AllowancR: number;
  ErrorAllowancR: string;
  allowanceMemberFunc(){

    this.AllowancR = null;
    this.ErrorAllowancR = "";

    var allowance = new PostMemberREQ();
    var values = new MemberAllowance();

    allowance.userName = this.inputEnterid;
    allowance.chaincodeFunction = 'memberallowance';

    values.myaccount = this.inputMyaccount;
    values.hisaccount = this.inputHisaccount;

    allowance.values = values;

    this._freeApiService.queryMemberPost(allowance).subscribe(
      data=>{
        this.MemberAllowanceResp = data;
        if (this.MemberAllowanceResp.returncode) {
          this.AllowancR =  this.MemberAllowanceResp.value;
        } else {
          this.ErrorAllowancR = "error message: " +  this.MemberAllowanceResp.errmessage;
        }
        this.inputEnterid = null;
        this.inputMyaccount = null;
        this.inputHisaccount = null;
      }
    );
  }

  //畫面輸入的欄位
  inputEnteridBal: string;
  inputAccountBal: string;
  //拆解後端的回覆 並顯示在頁面上
  BalanceR: MemberBalanceOfResp[] = [];
  memberBalanceOfFunc(){

    this.BalanceR = [];

    var memberbalance = new PostMemberREQ();
    var values = new MemberBalanceOf();

    memberbalance.userName = this.inputEnteridBal;
    memberbalance.chaincodeFunction = 'memberbalanceof';

    values.memberaccount = this.inputAccountBal;

    memberbalance.values = values;

    this._freeApiService.queryMemberPost(memberbalance).subscribe(
      data=>{
        for(var keys in data) {
          this.BalanceR.push({ key:keys, value:data[keys] });
        }

        this.inputEnteridBal = null;
        this.inputAccountBal = null;
      }
    );
  }

  //畫面輸入的欄位
  inputMemberAccountHIS: string;
  inputEnteridHIS: string;
  //收到後端的回覆
  objMemberAccountR: Array<historyMemberAccResp>;
  BalanceOfR: historyMemberBalanceOfResp[] = [];
  queryMemberAccountFunc(){

    this.objMemberAccountR = null;
    this.BalanceOfR = [];

    var tokenacc = new PostMemberREQ();
    var values = new MemberAccInfo();

    tokenacc.userName = this.inputEnteridHIS;
    tokenacc.chaincodeFunction = 'gethistoryofaccount';

    values.memberaccount = this.inputMemberAccountHIS;

    tokenacc.values = values;

    this._freeApiService.queryMemberPost(tokenacc).subscribe(
      data=>{
        this.objMemberAccountR = data;
        console.log(data.length);
        
        for(var keys in data) {
          this.BalanceOfR.push({ key:keys, value: JSON.stringify(data[keys]['Value']['holdingtokens']) });
        }
        // for (var key in data[3]['Value']['holdingtokens']){
        //   console.log(key);
        // }
        
        this.inputEnteridHIS = null;
        this.inputMemberAccountHIS = null;
      }
    );
  }


}
