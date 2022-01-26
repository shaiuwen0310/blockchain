export class PostTxnREQ {
    userName: string;
    chaincodeFunction: string;
    values: any;
}

export class CoinbaseAndMbrTxn {
    tokenname: string;
    tokenaccount: string;
    memberaccount: string;
    counts: number;
    walletid: string;
    choose: string;
}

export class CoinbaseAndMbrTxnResp {
    counts: number;
    errmessage: string;
    memberaccount: string;
    returncode: boolean;
    tokenaccount: string;
    tokenname: string;
}

export class InterMemberTxn {
    tokenname: string;
    memberfromaccount: string;
    membertoaccount: string;
    counts: number;
    walletid: string;
}

export class InterMemberTxnResp {
    tokenname: string;
    memberfromaccount: string;
    membertoaccount: string;
    counts: number;
    errmessage: string;
    returncode: boolean;
}

export class TokenExchangeTxn {
    memberacc: string;
    holdingtoken: string;
    holdingtokenacc: string;
    holdingtokennumber: number;
    exchangetoken: string;
    exchangetokenacc: string;
    walletid: string;
}

export class TokenExchangeTxnResp {
    account: string;
    returncode: string;
    errmessage: string;
}