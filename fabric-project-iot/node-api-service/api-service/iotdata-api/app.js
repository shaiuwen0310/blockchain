'use strict';

var log4js = require('log4js');
var logger = log4js.getLogger(process.env.LOGGER_LABEL);

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
var port = process.env.API_PORT;


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

app.post('/iotdata/:chaincodeName/invoke/v1', async function(req, res, next) {
	//合約名稱還是在url取值
	var chaincodeName = req.params.chaincodeName;
	//帳本(channel)名稱改放在json格式中，使外部打api時使用固定url
	var channelName = req.body.channelName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;

	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);

	let msg1 = await invoke.setHash(channelName, chaincodeName, userName, chaincodeFunction, values);
	logger.info("pid " + process.pid + ":: set res: " + msg1);

	// catch異常所組的json type是'string'，由chaincode組好的json type是'object'
	// JSON.parse(msg1)一直有json格式上的錯誤，所以改用type判斷
	// type為string沒意外就是rtnc99的回覆，並再次判斷確實是rtnc99
	if (typeof msg1 === 'string'){
		if (msg1.match(`"rtnc":99`)){
			res.send(msg1);
			//若fabric網路回應有錯誤或異常，node api沒有exit 1，則後續造成node api的log顯示peer timeout，且peer確實無相關log
			return next(process.exit(1));
		} else {
			res.send(msg1);
		}
	} else {
		res.send(msg1);
	}

});

app.post('/iotdata/:chaincodeName/query/v1', async function(req, res, next) {
	var chaincodeName = req.params.chaincodeName;
	var channelName = req.body.channelName;
	var userName = req.body.userName;
	var chaincodeFunction = req.body.chaincodeFunction;
	var values = req.body.values;

	checkargs.checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res);

	let msg1 = await query.getHash(channelName, chaincodeName, userName, chaincodeFunction, values);
	logger.info("pid " + process.pid + ":: get res: " + msg1);

	if (typeof msg1 === 'string'){
		if (msg1.match(`"rtnc":99`)){
			res.send(msg1);
			return next(process.exit(1));
		} else {
			res.send(msg1);
		}
	} else {
		res.send(msg1);
	}

});

app.post('/iotdata/asdce/a/v1', async function(req, res) {
	logger.info('===============enroll adminID===============');
	var values = req.body.values;
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.enrollAdmin(values);
	res.send(message);
});

app.post('/iotdata/asdce/u/v1', async function(req, res) {
	logger.info('===============enroll userID===============');
	var values = req.body.values;
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.registerUser(values);
	res.send(message);
});

