'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('mytokens-api');
var express = require('express');
var bodyParser = require('body-parser');
var http = require('http');
var app = express();
var cors = require('cors');

var invoke = require('./app/invoke.js');
var query = require('./app/query.js');
var asdce = require('./app/asdce.js');
var CheckArgs = require('./app/checking.js');
let checkargs = new CheckArgs();

var host = "127.0.0.1";
var port = "4006";

/**
 * PORT=4000 node app.js
 */

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// SET CONFIGURATONS ////////////////////////////
///////////////////////////////////////////////////////////////////////////////
app.options('*', cors());
app.use(cors());
//support parsing of application/json type post data
app.use(bodyParser.json());
//support parsing of application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({
	extended: false
}));

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// START SERVER /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var server = http.createServer(app).listen(port, function() {});
logger.info('****************** SERVER STARTED ************************');
logger.info('***************  http://%s:%s  ******************',host,port);
server.timeout = 240000;

function getErrorMessage(field) {
	var response = {
		success: false,
		message: field + ' field is missing or Invalid in the request'
	};
	return response;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////// REST ENDPOINTS START HERE ///////////////////////////
///////////////////////////////////////////////////////////////////////////////

app.post('/mytokens/:channelName/:chaincodeName/token/v1', async function(req, res) {
	logger.debug('===============新增 啟用 凍結 刪除 token===============');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;

	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);

	switch (chaincodeFunction) {
		case "newtoken":
			let msg1 = await invoke.newToken(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg1);
			break;
		case "activatetoken":
			let msg2 = await invoke.activateToken(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg2);
			break;
		case "freezenatoken":
			let msg3 = await invoke.freezenToken(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg3);
			break;
		case "deleteatoken":
			let msg4 = await invoke.deleteToken(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg4);
			break;
		default:
			res.send('app.js: does not match the function');
			break;
	}

});

app.post('/mytokens/:channelName/:chaincodeName/token/query/v1', async function(req, res) {
	logger.debug('===============token 完整資訊 總供應量 帳戶歷史資訊===============');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;

	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);

	switch (chaincodeFunction) {
		case "informationoftoken":
			let msg1 = await query.getTokenInfo(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg1);
			break;
		case "supplytotaloftoken":
			let msg2 = await query.getTokenSupplyTotal(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg2);
			break;
		case "historyoftokenaccount":
			let msg3 = await query.getHistoryOfTokenAccount(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg3);
			break;
		default:
			res.send('app.js: does not match the function');
			break;
	}

});

app.post('/mytokens/:channelName/:chaincodeName/member/v1', async function(req, res) {
	logger.debug('===============新增 啟用 凍結 會員帳號 或 進行approve===============');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;
	
	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);
	
	switch (chaincodeFunction) {
		case "newamemberaccount":
			let msg1 = await invoke.newMember(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg1);
			break;
		case "activatememberaccount":
			let msg2 = await invoke.activateMember(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg2);
			break;
		case "freezenmember":
			let msg3 = await invoke.freezenMember(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg3);
			break;
		case "memberapprove":
			let msg4 = await invoke.approveOfGiven(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg4);
			break;
		default:
			res.send('app.js: does not match the function');
			break;
	}
	
});

app.post('/mytokens/:channelName/:chaincodeName/member/query/v1', async function(req, res) {
	logger.debug('===============會員帳號 allowance 餘額 歷史資訊===============');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;
	
	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);
	
	switch (chaincodeFunction) {
		case "memberallowance":
			let msg1 = await query.getApproveOfValue(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg1);
			break;
		case "memberbalanceof":
			let msg2 = await query.getMemberBalance(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg2);
			break;
		case "gethistoryofaccount":
			let msg3 = await query.getHistoryOfAccount(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg3);
			break;
		default:
			res.send('app.js: does not match the function');
			break;
	}
	
});

app.post('/mytokens/:channelName/:chaincodeName/txn/v1', async function(req, res) {
	logger.debug('===============token帳號與會員之間轉讓token 會員之間轉讓token 會員擁有的token換成其他token===============');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;
	
	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);
	
	switch (chaincodeFunction) {
		case "transfers":
			let msg1 = await invoke.CoinBaseAndMemberTxn(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg1);
			break;
		case "transferfroms":
			let msg3 = await invoke.Member1ToMember2(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg3);
			break;
		case "exchangetoken":
			let msg4 = await invoke.TokenExchangeToken(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg4);
			break;
		default:
			res.send('app.js: does not match the function');
			break;
	}
	
});

app.post('/mytokens/asdce/a/v1', async function(req, res) {
	logger.debug('===============新增新admin===============');
	var values = req.body.values;
	logger.debug('values  : ' + values);
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.enrollAdmin(values);
	res.send(message);
});

app.post('/mytokens/asdce/u/v1', async function(req, res) {
	logger.debug('===============新增新user===============');
	var values = req.body.values;
	logger.debug('values  : ' + values);
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.registerUser(values);
	res.send(message);
});