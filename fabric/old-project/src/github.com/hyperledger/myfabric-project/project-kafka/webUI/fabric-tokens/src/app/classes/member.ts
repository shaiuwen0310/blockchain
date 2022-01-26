export class PostMemberREQ {
    userName: string;
    chaincodeFunction: string;
    values: any;
}

export class NewMember {
    membername: string;
    account: string;
    state: number;
    holdingtokens: Map<string, number>;
    walletid: string;
}

export class MemberResp {
    account: string;
    errmessage: string;
    returncode: boolean;
}

export class ActivateMember {
    account: string;
    walletid: string;
}

export class ApprovalMember {
    myaccount: string;
    hisaccount: string;
    value: number;
    walletid: string;
}

export class ApprovalMemberResp {
    myaccount: string;
    hisaccount: string;
    value: number;
    errmessage: string;
    returncode :boolean;
}

export class MemberAllowance {
    myaccount: string;
    hisaccount: string;
}

export class AllowanceMemberResp {
    myaccount: string;
    hisaccount: string;
    value: number;
    errmessage: string;
    returncode :boolean;
}

export class MemberBalanceOf {
    memberaccount: string;
}

export class MemberBalanceOfResp {
    key: string;
    value: number;
}

export class MemberAccInfo {
    memberaccount: string;
}

export class historyMemberAccResp {
    TxId: string;
    Value: any;
    Timestamp: string;
    IsDelete: string;
}

export class historyMemberBalanceOfResp {
    key: string;
    value: string;
}