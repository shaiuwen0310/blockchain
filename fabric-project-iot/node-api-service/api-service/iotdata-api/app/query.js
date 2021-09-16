'use strict';

var log4js = require('log4js');
var logger = log4js.getLogger(process.env.LOGGER_LABEL);

const Config = require('./config.js');
const config = new Config();
const ccp = config.netConfig();

const Wallet = require('./wallet.js');
const wt = new Wallet();
const wallet = wt.wallet();

const GetContract = require('./getcontract.js');

var getHash = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    var err_rtn = `{"txid":${values.txid},"time":${values.time},"rtnc":99,"hash":null,"device":null}`;

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        logger.info("pid " + process.pid + ":: get arg: " + channelName + ", " + chaincodeName + ", " + userName + ", " + chaincodeFunction + ", " + values.txid + ", " + values.time);
        const result = await contract.evaluateTransaction(chaincodeFunction, values.txid, values.time);
        logger.info("pid " + process.pid + ':: get sts: Transaction has been evaluate');

        return result

    } catch (error) {
        logger.error("pid " + process.pid + `:: get sts :Failed to evaluate transaction:`);
        logger.error("pid " + process.pid + ":: get rsn :" + `${error.toString()}`);
	    return err_rtn;
        //process.exit(1);
    }
};

exports.getHash = getHash;
