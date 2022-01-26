'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('snsrdata-api');
var express = require('express');
var bodyParser = require('body-parser');
var http = require('http');
var app = express();
var cors = require('cors');

var invoke = require('./app/invoke.js');
var query = require('./app/query.js');
var CheckArgs = require('./app/checking.js');
let checkargs = new CheckArgs();

var asdce = require('./app/asdce.js');

var host = "127.0.0.1";
var port = "4001";

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

app.post('/snsrdata/mychannel/snsrdatacc/set/:userName/v1', async function(req, res) {
	logger.debug('=============== set ===============');
	var userName = req.params.userName;
	var values = req.body.values;
	var key = req.body.key;

	checkargs.checkArgs("mychannel", "snsrdatacc", userName, "set", values, key, res);
	// let msg1 = await invoke.setContent("mychannel", "snsrdatacc", userName, "set", values, key);
	let msg1 = await invoke.setContent("mychannel", "snsrdatacc", userName, "set", values, key);
	res.send(msg1);
});

app.post('/snsrdata/mychannel/snsrdatacc/vhist/:userName/v1', async function(req, res) {
	logger.debug('=============== vhist ===============');
	var userName = req.params.userName;
	var values = req.body.values;

	checkargs.checkArgs("mychannel", "snsrdatacc", userName, "vhist", values, res);
	let msg1 = await query.getHistByUuid("mychannel", "snsrdatacc", userName, "vhist", values);
	res.send(msg1);
});

app.post('/id/asdce/a/v1', async function(req, res) {
	logger.debug('===============新增新admin===============');
	var values = req.body.values;
	logger.debug('values  : ' + values);
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.enrollAdmin(values);
	res.send(message);
});

app.post('/id/asdce/u/v1', async function(req, res) {
	logger.debug('===============新增新user===============');
	var values = req.body.values;
	logger.debug('values  : ' + values);
	if (!values) { res.json(getErrorMessage('\'values\'')); return; }

	let message = await asdce.registerUser(values);
	res.send(message);
});