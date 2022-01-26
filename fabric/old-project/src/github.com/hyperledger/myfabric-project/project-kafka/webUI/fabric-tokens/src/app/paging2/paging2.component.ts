import { Component, OnInit } from '@angular/core';

import { freeApiService }    from '../services/freeapi.service';


import { PostMemberREQ, NewMember, MemberResp, ActivateMember, ApprovalMember, ApprovalMemberResp } from '../classes/member';






@Component({
  selector: 'app-paging2',
  templateUrl: './paging2.component.html',
  styleUrls: ['./paging2.component.css']
})
export class Paging2Component implements OnInit {

  constructor(private _freeApiService: freeApiService) { }

  ngOnInit() {
  }

  //畫面輸入的欄位
  inputMembername: string;
  inputAccount: string;
  inputEnterid: string;
  //收到後端的回覆
  objNewMemberResp:MemberResp;
  //顯示在頁面上
  newMemberR: string;
  newMemberFunc(){

    this.newMemberR = "";

    var newmember = new PostMemberREQ();
    var values = new NewMember();

    newmember.userName = this.inputEnterid;
    newmember.chaincodeFunction = 'newamemberaccount';

    values.membername = this.inputMembername;
    values.account = this.inputAccount;
    values.walletid = this.inputEnterid;

    newmember.values = values;

    this._freeApiService.invokeMemberPost(newmember).subscribe(
      data=>{
        this.objNewMemberResp = data;
        if (this.objNewMemberResp.returncode) {
          this.newMemberR = "Building " + this.objNewMemberResp.account + " successfully!";
          this.inputEnterid = null;
          this.inputMembername = null;
          this.inputAccount = null;
        } else {
          this.newMemberR = "error message: " +  this.objNewMemberResp.errmessage;
        }
      }
    );
  }

  //畫面輸入的欄位
  inputAccountACT: string;
  inputEnteridACT: string;
  //收到後端的回覆
  objActMemberResp:MemberResp;
  //顯示在頁面上
  actMemberR: string;
  activateMemberFunc(){

    this.actMemberR = "";

    var activatemember = new PostMemberREQ();
    var values = new ActivateMember();

    activatemember.userName = this.inputEnteridACT;
    activatemember.chaincodeFunction = 'activatememberaccount';

    values.account = this.inputAccountACT;
    values.walletid = this.inputEnteridACT;

    console.log(typeof values.walletid)

    activatemember.values = values;

    this._freeApiService.invokeMemberPost(activatemember).subscribe(
      data=>{
        this.objActMemberResp = data;
        if (this.objActMemberResp.returncode) {
          this.actMemberR = "Acitivating " + this.objActMemberResp.account + " successfully!";
          this.inputEnteridACT = null;
          this.inputAccountACT = null;
        } else {
          this.actMemberR = "error message: " +  this.objActMemberResp.errmessage;
        }
      }
    );
  }

  //畫面輸入的欄位
  inputMyaccount: string;
  inputHisaccount: string;
  inputValue: number;
  inputApproveenterid: string;
  //收到後端的回覆
  objMemberApprovalResp:ApprovalMemberResp;
  //顯示在頁面上
  approvalMemberR: string;
  approvalMemberFunc(){

    this.approvalMemberR = "";

    var approvemember = new PostMemberREQ();
    var values = new ApprovalMember();

    approvemember.userName = this.inputApproveenterid;
    approvemember.chaincodeFunction = 'memberapprove';

    values.myaccount = this.inputMyaccount;
    values.hisaccount = this.inputHisaccount;
    values.value = this.inputValue;
    values.walletid = this.inputApproveenterid;

    approvemember.values = values;

    this._freeApiService.invokeMemberPost(approvemember).subscribe(
      data=>{
        this.objMemberApprovalResp = data;
        if (this.objMemberApprovalResp.returncode) {
          this.approvalMemberR =  this.objMemberApprovalResp.myaccount + " can give "  + this.objMemberApprovalResp.hisaccount + " " + this.objMemberApprovalResp.value + " worth of tokens.";
        } else {
          this.approvalMemberR = "error message: " +  this.objMemberApprovalResp.errmessage;
        }
        this.inputMyaccount = null;
        this.inputHisaccount = null;
        this.inputValue = null;
        this.inputApproveenterid = null;
      }
    );
  }

}
