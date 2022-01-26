'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('SampleWebApp');
var express = require('express');
var bodyParser = require('body-parser');
var http = require('http');
var app = express();
var cors = require('cors');

var query = require('./app/query.js');
var invoke = require('./app/invoke.js');
var del = require('./app/delete.js');

var host = "127.0.0.1";
var port = "4000";

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

app.post('/wine/:channelName/:chaincodeName/invoke/v1', async function(req, res) {
	var chaincodeName = req.params.chaincodeName;
	var channelName = req.params.channelName;
	var userName = req.body.userName;
	var fcn = req.body.fcn;
	var args = req.body.args;
	logger.debug('channelName  : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('userName : ' + userName);
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);
	if (!chaincodeName){ res.json(getErrorMessage('\'chaincodeName\''));return; }
	if (!channelName)  { res.json(getErrorMessage('\'channelName\''));  return; }
	if (!userName) { res.json(getErrorMessage('\'userName\'')); return; }
	if (!fcn)  { res.json(getErrorMessage('\'fcn\''));  return; }
	if (!args) { res.json(getErrorMessage('\'args\'')); return; }

	switch (fcn) {
		case 'createWine':
			logger.debug('==================== 新增一筆資料 ==================');
			let message1 = await invoke.insertOneRecord(channelName, chaincodeName, userName, fcn, args);
			res.send(message1);
			break;
		case 'createWinefromJsonFile':
			logger.debug('==================== 新增一筆json格式的資料 ==================');
			let message2 = await invoke.insertJsonRecord(channelName, chaincodeName, userName, fcn, args);
			res.send(message2);
			break;
		case 'createWinefromJsonFile-hdfs':
			logger.debug('==================== 新增一筆json格式的資料 fromHDFS AND args is file name ==================');
			let message3 = await invoke.insertHDFSRecord(channelName, chaincodeName, userName, 'createWinefromJsonFile', args);
			res.send(message3);
			break;
		default:
			res.send('switch case no equal function');
			break;
	}
});

app.get('/wine/:channelName/:chaincodeName/query/v1', async function(req, res) {
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	let values = req.query.values;
	let fcn = req.query.fcn;
	let usr = req.query.usr;
	logger.debug('channelName : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn : ' + fcn);
	logger.debug('usr : ' + usr);
	logger.debug('values : ' + values);

	if (!chaincodeName){ res.json(getErrorMessage('\'chaincodeName\'')); return;}
	if (!channelName)  { res.json(getErrorMessage('\'channelName\''));  return; }
	if (!fcn) { res.json(getErrorMessage('\'fcn\'')); return; }
	if (!usr) { res.json(getErrorMessage('\'usr\'')); return; }
	if (!values){ res.json(getErrorMessage('\'values\'')); return;}

	switch (fcn) {
		case 'queryWine':
			logger.debug('================== 透過key值抓取value ==================');
			let msg1 = await query.queryWineBYkey(channelName, chaincodeName, usr, fcn, values);
			res.send(msg1);
			break;
		case 'getHistoryForWine':
			logger.debug('================== 透過key值抓取歷史資料 ==================');
			let msg2 = await query.queryWineHistoryBYkey(channelName, chaincodeName, usr, fcn, values);
			res.send(msg2);
			break;
		case 'queryWineByPlace':
			logger.debug('================== 富查詢 透過Place欄位抓取資料 ==================');
			let msg3 = await query.queryWineByPlace(channelName, chaincodeName, usr, fcn, values);
			res.send(msg3);
			break;
		default:
			res.send('switch case no equal function');
			break;
	}
});

app.get('/wine/:channelName/:chaincodeName/pagination/v1', async function(req, res) {
	logger.debug('================== 富查詢 分頁查詢 ================');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	let fld = req.query.fld;
	let val = req.query.val;
	let page = req.query.page;
	let tag = req.query.tag;
	let fcn = req.query.fcn;
	let usr = req.query.usr;

	logger.debug('channelName : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn : ' + fcn);
	logger.debug('usr : ' + usr);
	logger.debug('fld : ' + fld);
	logger.debug('val : ' + val);
	logger.debug('page : ' + page);
	logger.debug('tag : ' + tag);

	if (!chaincodeName){ res.json(getErrorMessage('\'chaincodeName\''));return;}
	if (!channelName)  { res.json(getErrorMessage('\'channelName\'')); return; }
	if (!fcn)  { res.json(getErrorMessage('\'fcn\'')); return; }
	if (!usr)  { res.json(getErrorMessage('\'usr\'')); return; }
	if (!fld)  { res.json(getErrorMessage('\'fld\'')); return; }
	if (!val)  { res.json(getErrorMessage('\'val\'')); return; }
	if (!page) { res.json(getErrorMessage('\'page\'')); return;}
	if (!tag)  { res.json(getErrorMessage('\'tag\'')); return; }

	if (tag === "nil") tag = "";
	let message = await query.queryWinesWithPagination(channelName, chaincodeName, usr, fcn, fld, val, page, tag);
	res.send(message);
});

app.get('/wine/:channelName/:chaincodeName/delete/v1', async function(req, res) {
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	let values = req.query.values;
	let fcn = req.query.fcn;
	let usr = req.query.usr;

	logger.debug('channelName : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn : ' + fcn);
	logger.debug('usr : ' + usr);
	logger.debug('values : ' + values);

	if (!chaincodeName){ res.json(getErrorMessage('\'chaincodeName\'')); return;}
	if (!channelName)  { res.json(getErrorMessage('\'channelName\''));  return; }
	if (!fcn) { res.json(getErrorMessage('\'fcn\'')); return; }
	if (!usr) { res.json(getErrorMessage('\'usr\'')); return; }
	if (!values){ res.json(getErrorMessage('\'values\'')); return;}

	let message = await del.deleteRecordBYKey(channelName, chaincodeName, usr, fcn, values);
	res.send(message);
});
