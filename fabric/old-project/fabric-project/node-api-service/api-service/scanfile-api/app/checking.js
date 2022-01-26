
'use strict';

var log4js = require('log4js');
var logger = log4js.getLogger('scanfile-api');

class CheckArgs {

    async checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res){
        logger.debug('channelName  : ' + channelName);
        logger.debug('chaincodeName : ' + chaincodeName);
        logger.debug('userName : ' + userName);
        logger.debug('chaincodeFunction  : ' + chaincodeFunction);
        logger.debug('values  : ' + values);
        if (!chaincodeName){ res.json(getErrorMessage('\'chaincodeName\''));return; }
        if (!channelName)  { res.json(getErrorMessage('\'channelName\''));  return; }
        if (!userName) { res.json(getErrorMessage('\'userName\'')); return; }
        if (!chaincodeFunction)  { res.json(getErrorMessage('\'chaincodeFunction\''));  return; }
        if (!values) { res.json(getErrorMessage('\'values\'')); return; }
    }

}

module.exports = CheckArgs;