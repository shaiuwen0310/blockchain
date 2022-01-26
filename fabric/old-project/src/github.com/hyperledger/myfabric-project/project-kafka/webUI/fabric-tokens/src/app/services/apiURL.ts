const head = "http://"
const IP = "127.0.0.1";
// const IP = "192.168.101.251";
const PORT = ":4003";
const Domain = head + IP + PORT;

// newtoken activateToken freezenatoken deleteatoken
export const invokeTokenURL = Domain + "/mytokens/mychannel/mytokenscc/token/v1";

// informationoftoken supplytotaloftoken historyoftokenaccount 
export const queryTokenURL = Domain + "/mytokens/mychannel/mytokenscc/token/query/v1";

// newamemberaccount activatememberaccount freezenmember memberapprove
export const invokeMemberURL = Domain + "/mytokens/mychannel/mytokenscc/member/v1";

// memberallowance memberbalanceof CheckApproveValue gethistoryofaccount
export const queryMemberURL = Domain + "/mytokens/mychannel/mytokenscc/member/query/v1";

// transfers transferfroms exchangetoken
export const txnURL = Domain + "/mytokens/mychannel/mytokenscc/txn/v1";


