
'use strict';

var log4js = require('log4js');
var logger = log4js.getLogger(process.env.LOGGER_LABEL);

class CheckArgs {

    async checkArgs(channelName, chaincodeName, userName, chaincodeFunction, values, res){

        if (!chaincodeName){ res.json(getErrorMessage('\'chaincodeName\''));return; }
        if (!channelName)  { res.json(getErrorMessage('\'channelName\''));  return; }
        if (!userName) { res.json(getErrorMessage('\'userName\'')); return; }
        if (!chaincodeFunction)  { res.json(getErrorMessage('\'chaincodeFunction\''));  return; }
        if (!values) { res.json(getErrorMessage('\'values\'')); return; }
    }

}

module.exports = CheckArgs;