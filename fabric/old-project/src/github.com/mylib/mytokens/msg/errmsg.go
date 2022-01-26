package msg

var (
	// token
	FailedToGetToken          = "Failed to get token: "
	ThisTokenAlreadyExists    = "This token already exists: "
	ThisTokenIsNotExists      = "This token is not exists: "
	ThisTokenIsAlreadyFreezen = "This token is already freezen"
	FailToDeleteTheToken      = "fail to delete the token"

	// token account
	FailedToGetTokenAccount        = "Failed to get token account: "
	ThisTokenAccountIsNotExists    = "This token account is not exists: "
	ParameterInTokenAccountIsWrong = "This token account is not enable or the balance is not 0"

	// check number of arguments
	IncorrectNumberOfArguments = "Incorrect number of arguments. Expecting "

	// member account
	FailedToGetMemberAccount                    = "Failed to get member account: "
	ThisMemberAccountIsAlreadyExists            = "This member account is already exists: "
	ThisMemberAccountIsNotExists                = "This member account is not exists: "
	ThisMemberAccountIsNotEnable                = "This member account is not enable: "
	MemberAccountIsNotEnable                    = "Member account is not enable: "
	ThisMemberIsAlreadyFreezen                  = "This member is already freezen"
	MembesTokenIsNotEnough                      = "Member's token is not enough"
	HoldingTokensBalanceIsNotEnough             = "Holding token's balance is not enough"
	HoldingTokensBalanceIsLessThanExchangeToken = "Holding token's balance is less than exchange token"

	// token's value
	TheValueISInvalid = "The value is invalid "

	//erc20 approve allowance
	FailedToGetTheApproval       = "Failed to get the approval "
	ThisApprovalIsNotExists      = "This approval is not exists "
	ThisIsNotYourApprovalAccount = "This is not your approval account "

	OneOfAccountIsNotEnable = "One of account is not enable "

	FailedAllowance         = "Failed allowance: "
	FailedToTransformTokens = "Failed to transform tokens"
	YourCountsAreTooMany    = "Your counts are too many"
)
