
'use strict';

var log4js = require('log4js');
var logger = log4js.getLogger('mytoken-api');

class CheckArgs {

    async checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, key, res){
        logger.debug('channelName  : ' + channelName);
        logger.debug('chaincodeName : ' + chaincodeName);
        logger.debug('userName : ' + userName);
        logger.debug('chaincodeFunction  : ' + chaincodeFunction);
        logger.debug('values  : ' + values);
        logger.debug('key  : ' + key);
        if (!chaincodeName){ res.json(getErrorMessage('\'chaincodeName\''));return; }
        if (!channelName)  { res.json(getErrorMessage('\'channelName\''));  return; }
        if (!userName) { res.json(getErrorMessage('\'userName\'')); return; }
        if (!chaincodeFunction)  { res.json(getErrorMessage('\'chaincodeFunction\''));  return; }
        if (!values) { res.json(getErrorMessage('\'values\'')); return; }
        if (!key) { res.json(getErrorMessage('\'key\'')); return; }
    }

}

module.exports = CheckArgs;