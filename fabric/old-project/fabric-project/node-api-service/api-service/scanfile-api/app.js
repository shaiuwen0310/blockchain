'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('scanfile-api');
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
var port = "4005";


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

///////////////////////////////////////////////////////////////////////////////
///////////////////////// REST ENDPOINTS START HERE ///////////////////////////
///////////////////////////////////////////////////////////////////////////////

app.post('/scanfile/:channelName/:chaincodeName/invoke/v1', async function(req, res) {
	logger.info('===============儲存圖片hash值===============');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;

	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);
	let msg1 = await invoke.setImageHash(channelName, chaincodeName, userName, chaincodeFunction, values);
	res.send(msg1);

});

app.post('/scanfile/:channelName/:chaincodeName/query/v1', async function(req, res) {
	logger.info('===============用txid hash serialNum來查詢圖片hash值是否已存在 查詢歷史資訊===============');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;

	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);

	switch (chaincodeFunction) {
		case "vtxid":
			let msg1 = await query.checkByTxid(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg1);
			break;
		case "vhash":
			let msg2 = await query.checkByHash(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg2);
			break;
		case "vserialno":
			let msg3 = await query.checkBySerialNum(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg3);
			break;
		case "vserialnoblockid":
			let msg4 = await query.checkBySerialNumBlockId(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg4);
			break;
		case "gethistory":
			let msg5 = await query.getHistoryByHash(channelName, chaincodeName, userName, chaincodeFunction, values);
			res.send(msg5);
			break;
		default:
			res.send('app.js: does not match the function');
			break;
	}

});

app.post('/scanfile/asdce/a/v1', async function(req, res) {
	logger.info('===============新增新admin===============');
	var values = req.body.values;
	logger.debug('values  : ' + values);
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.enrollAdmin(values);
	res.send(message);
});

app.post('/scanfile/asdce/u/v1', async function(req, res) {
	logger.info('===============新增新user===============');
	var values = req.body.values;
	logger.debug('values  : ' + values);
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.registerUser(values);
	res.send(message);
});