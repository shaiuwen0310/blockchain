package data

//token資訊
type TokenInfo struct {
	Name        string `json:"name"`
	Symbol      string `json:"symbol"`
	Value       uint64 `json:"value"`
	State       uint64 `json:"state"`
	SupplyTotal uint64 `json:"supplytotal"`
	Corporation string `json:"corporation"`
	Walletid    string `json:"walletid"`
}

//token帳號資訊
type TokenAccount struct {
	TokenName string `json:"tokenname"`
	Account   string `json:"account"`
	Balance   uint64 `json:"balance"`
	State     uint64 `json:"state"`
	Walletid  string `json:"walletid"`
}

//會員帳號
type MemberAccount struct {
	MemberName    string            `json:"membername"`
	Account       string            `json:"account"`
	State         uint64            `json:"state"`
	HoldingTokens map[string]uint64 `json:"holdingtokens"`
	Walletid      string            `json:"walletid"`
}

//每次交易的token 可交易的最高價值
type ApproveValue struct {
	MyAccount  string `json:"myaccount"`
	HisAccount string `json:"hisaccount"`
	ApproveOf  uint64 `json:"approveof"`
	WalletId   string `json:"walletid"`
}
