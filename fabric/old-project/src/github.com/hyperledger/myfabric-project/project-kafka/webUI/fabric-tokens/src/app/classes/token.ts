
// 所有token的request
export class PostTokenREQ {
    userName: string;
    chaincodeFunction: string;
    values: any;
}

// 所有invoke token的response
export class TokenResp {
    tokenname: string;
    errmessage: string;
    returncode: boolean;
}
// new token的value
export class NewToken {
    tokenname: string;
    symbol: string;
    value: number;
    total: number;
    tokenaccount: string;
    corporation: string;
    walletid: string;
}
// 啟用 凍結 刪除token的value
export class invokeToken {
    tokenname: string;
    tokenaccount: string;
    walletid: string;
}

// 抓取token資訊的value
export class queryTokenInfo {
    tokenname: string;
}

// token info的respone
export class TokenInfoResp {
    corporation: string;
    name: string;
    state: number;
    supplytotal: number;
    symbol: string;
    value: number;
    walletid: string;
}

// token supply的respone
export class TokenSupplyResp {
    tokenname: string;
    errmessage: string;
    returncode: boolean;
    result: number;
}

// 抓取token account資訊的value
export class queryTokenAccInfo {
    tokenname: string;
    tokenaccount: string;
}

// token account歷史資訊的respone
export class historyTokenAccResp {
    TxId: string;
    Value: any;
    Timestamp: string;
    IsDelete: string;
}