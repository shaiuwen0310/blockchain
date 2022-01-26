import { Component, OnInit } from '@angular/core';

import { freeApiService }    from '../services/freeapi.service';

import { PostTokenREQ, queryTokenInfo, TokenInfoResp, queryTokenAccInfo, historyTokenAccResp }    from '../classes/token';


@Component({
  selector: 'app-paging4',
  templateUrl: './paging4.component.html',
  styleUrls: ['./paging4.component.css']
})
export class Paging4Component implements OnInit {

  constructor(private _freeApiService: freeApiService) { }

  ngOnInit() {
  }

  //畫面輸入的欄位
  inputtokennameINFO: string;
  inputenteridINFO: string;
  //收到後端的回覆
  objTokenInfo:TokenInfoResp;
  queryTokenInfoFunc(){

    this.objTokenInfo = null;
    
    var tokeninfo = new PostTokenREQ();
    var values = new queryTokenInfo();

    tokeninfo.userName = this.inputenteridINFO;
    tokeninfo.chaincodeFunction = 'informationoftoken';

    values.tokenname = this.inputtokennameINFO;

    tokeninfo.values = values;

    this._freeApiService.queryTokenPost(tokeninfo).subscribe(
      data=>{
        this.objTokenInfo = data;
        console.log(data);
        this.inputtokennameINFO = null;
        this.inputenteridINFO = null;
      }
    );
  }

  //畫面輸入的欄位
  inputtokennameSUP: string;
  inputenteridSUP: string;
  //收到後端的回覆
  tokenSupplyR:TokenInfoResp;
  queryTokenSupplyFunc(){

    this.tokenSupplyR = null;

    var tokensupply = new PostTokenREQ();
    var values = new queryTokenInfo();

    tokensupply.userName = this.inputenteridSUP;
    tokensupply.chaincodeFunction = 'supplytotaloftoken';

    values.tokenname = this.inputtokennameSUP;

    tokensupply.values = values;

    this._freeApiService.queryTokenPost(tokensupply).subscribe(
      data=>{
        this.tokenSupplyR = data;
        console.log(data);
        this.inputtokennameSUP = null;
        this.inputenteridSUP = null;
      }
    );
  }

  //畫面輸入的欄位
  inputtokennameHIS: string;
  inputtokenaccountHIS: string;
  inputenteridHIS: string;
  //收到後端的回覆
  objtokenAccountR: Array<historyTokenAccResp>;
  queryTokenAccountFunc(){

    this.objtokenAccountR = null;

    var tokenacc = new PostTokenREQ();
    var values = new queryTokenAccInfo();

    tokenacc.userName = this.inputenteridHIS;
    tokenacc.chaincodeFunction = 'historyoftokenaccount';

    values.tokenname = this.inputtokennameHIS;
    values.tokenaccount = this.inputtokenaccountHIS;

    tokenacc.values = values;

    this._freeApiService.queryTokenPost(tokenacc).subscribe(
      data=>{
        this.objtokenAccountR = data;
        console.log(this.objtokenAccountR);
        this.inputtokennameHIS = null;
        this.inputenteridHIS = null;
        this.inputtokenaccountHIS = null;
      }
    );
  }



}
