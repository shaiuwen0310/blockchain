import { Component, OnInit } from '@angular/core';

import { freeApiService }    from '../services/freeapi.service';





import { PostTokenREQ, TokenResp }    from '../classes/token';
import { NewToken, invokeToken }    from '../classes/token';


@Component({
  selector: 'app-paging1',
  templateUrl: './paging1.component.html',
  styleUrls: ['./paging1.component.css']
})
export class Paging1Component implements OnInit {

  constructor(private _freeApiService: freeApiService) { }

  ngOnInit() {
  }
  
  //收到後端的回覆
  objTokenResp:TokenResp;

  //畫面輸入的欄位
  inputTokenname: string;
  inputSymbol: string;
  inputValue: number;
  inputTotal: number;
  inputAccount: string;
  inputCorporation: string;
  inputEnterid: string;
  //顯示在頁面上
  newTokenR: string;
  newTokenFunc(){
    
    this.newTokenR = "";

    var newtoken = new PostTokenREQ();
    var values = new NewToken();

    newtoken.userName = this.inputEnterid;
    newtoken.chaincodeFunction = 'newtoken';

    values.tokenname = this.inputTokenname;
    values.symbol = this.inputSymbol;
    values.value = this.inputValue;
    values.total = this.inputTotal;
    values.tokenaccount = this.inputAccount;
    values.corporation = this.inputCorporation;
    values.walletid = this.inputEnterid;

    newtoken.values = values;

    this._freeApiService.invokeTokenPost(newtoken).subscribe(
      data=>{
        this.objTokenResp = data;
        if (this.objTokenResp.returncode) {
          this.newTokenR = "Building " + this.objTokenResp.tokenname + " successfully!";
          this.inputTokenname = null;
          this.inputSymbol = null;
          this.inputValue = null;
          this.inputTotal = null;
          this.inputAccount = null;
          this.inputCorporation = null;
          this.inputEnterid = null;
        } else {
          this.newTokenR = "error message: " +  this.objTokenResp.errmessage;
        }
      }
    );
  }

  //畫面輸入的欄位
  inputTokennameACT: string;
  inputAccountACT: string;
  inputEnteridACT: string;
  //顯示在頁面上
  activateTokenR: string;
  activateTokenFunc(){

    this.activateTokenR = "";

    var activatetoken = new PostTokenREQ();
    var values = new invokeToken();

    activatetoken.userName = this.inputEnteridACT;
    activatetoken.chaincodeFunction = 'activatetoken';

    values.tokenname = this.inputTokennameACT;
    values.tokenaccount = this.inputAccountACT;
    values.walletid = this.inputEnteridACT;

    activatetoken.values = values;

    this._freeApiService.invokeTokenPost(activatetoken).subscribe(
      data=>{
        this.objTokenResp = data;
        if (this.objTokenResp.returncode) {
          this.activateTokenR = "Activating " + this.objTokenResp.tokenname + " successfully!";
          this.inputEnteridACT = null;
          this.inputTokennameACT = null;
          this.inputAccountACT = null;
        } else {
          this.activateTokenR = "error message: " +  this.objTokenResp.errmessage;
        }
      }
    );
  }

  //畫面輸入的欄位
  inputTokennameFRZ: string;
  inputAccountFRZ: string;
  inputEnteridFRZ: string;
  //顯示在頁面上
  freezenTokenR: string;
  freezenTokenFunc(){

    this.freezenTokenR = "";

    var freezentoken = new PostTokenREQ();
    var values = new invokeToken();

    freezentoken.userName = this.inputEnteridFRZ;
    freezentoken.chaincodeFunction = 'freezenatoken';

    values.tokenname = this.inputTokennameFRZ;
    values.tokenaccount = this.inputAccountFRZ;
    values.walletid = this.inputEnteridFRZ;

    freezentoken.values = values;

    this._freeApiService.invokeTokenPost(freezentoken).subscribe(
      data=>{
        this.objTokenResp = data;
        if (this.objTokenResp.returncode) {
          this.freezenTokenR = "Freezen " + this.objTokenResp.tokenname + " successfully!";
          this.inputEnteridFRZ = null;
          this.inputTokennameFRZ = null;
          this.inputAccountFRZ = null;
        } else {
          this.freezenTokenR = "error message: " +  this.objTokenResp.errmessage;
        }
      }
    );
  }

  //畫面輸入的欄位
  inputTokennameDEL: string;
  inputAccountDEL: string;
  inputEnteridDEL: string;
  //顯示在頁面上
  deleteTokenR: string;
  deleteTokenFunc(){

    this.deleteTokenR = "";

    var deletetoken = new PostTokenREQ();
    var values = new invokeToken();

    deletetoken.userName = this.inputEnteridDEL;
    deletetoken.chaincodeFunction = 'deleteatoken';

    values.tokenname = this.inputTokennameDEL;
    values.tokenaccount = this.inputAccountDEL;
    values.walletid = this.inputEnteridDEL;

    deletetoken.values = values;

    this._freeApiService.invokeTokenPost(deletetoken).subscribe(
      data=>{
        this.objTokenResp = data;
        if (this.objTokenResp.returncode) {
          this.deleteTokenR = "Delete " + this.objTokenResp.tokenname + " successfully!";
          this.inputEnteridDEL = null;
          this.inputTokennameDEL = null;
          this.inputAccountDEL = null;
        } else {
          this.deleteTokenR = "error message: " +  this.objTokenResp.errmessage;
        }
      }
    );
  }

}
