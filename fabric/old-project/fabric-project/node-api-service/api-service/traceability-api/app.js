'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('traceability-api');
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


///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// SET CONFIGURATONS ////////////////////////////
///////////////////////////////////////////////////////////////////////////////
app.use(bodyParser.json({limit : "6300000kb"}));
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

///////////////////////////////////////////////////////////////////////////////
///////////////////////// REST ENDPOINTS START HERE ///////////////////////////
///////////////////////////////////////////////////////////////////////////////

app.post('/traceability/:channelName/:chaincodeName/invoke/v1', async function(req, res) {
	logger.info('===============新增/驗證/刪除資料===============');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;

	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);

	switch (chaincodeFunction) {
		case "set":
			let msg1 = await invoke.setInfo(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg1);
			break;
		case "verify":
			let msg2 = await invoke.verifyInfo(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg2);
			break;
		case "del":
			let msg3 = await invoke.delInfo(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg3);
			break;
		default:
			res.send('app.js: function unavailable');
			break;
	}

});

app.post('/traceability/:channelName/:chaincodeName/query/v1', async function(req, res) {
	logger.info('===============查詢總數量/使用hash值查詢===============');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;

	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);

	switch (chaincodeFunction) {
		case "quantity":
			let msg1 = await query.quantityInfo(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg1);
			break;
		case "checkbyhash":
			let msg2 = await query.checkByHash(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg2);
			break;
		default:
			res.send('app.js: function unavailable');
			break;
	}

});

app.post('/traceability/asdce/a/v1', async function(req, res) {
	logger.info('===============新增新admin===============');
	var values = req.body.values;
	logger.debug('values  : ' + values);
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.enrollAdmin(values);
	res.send(message);
});

app.post('/traceability/asdce/u/v1', async function(req, res) {
	logger.info('===============新增新user===============');
	var values = req.body.values;
	logger.debug('values  : ' + values);
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.registerUser(values);
	res.send(message);
});