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

var setHash = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    var err_rtn = `{"device":${values.hash},"hash":${values.device},"rtnc":99,"time":null,"txid":null}`;

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        logger.info("pid " + process.pid + ":: set arg: " + channelName + ", " + chaincodeName + ", " + userName + ", " + chaincodeFunction + ", " + values.hash + ", " + values.device);
        const result = await contract.submitTransaction(chaincodeFunction, values.hash, values.device);
	    logger.info("pid " + process.pid + ':: set sts: Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        logger.error("pid " + process.pid + `:: set sts :Failed to submit transaction:`);
        logger.error("pid " + process.pid + ":: set rsn :" + `${error}`);
	    return err_rtn;
        //process.exit(1);
    }

}

exports.setHash = setHash;
