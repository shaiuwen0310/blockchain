/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const Config = require('./config.js');
const config = new Config();
const ccp = config.netConfig();

const Wallet = require('./wallet.js');
const wt = new Wallet();
const wallet = wt.wallet();

const GetContract = require('./getcontract.js');

var quantityInfo = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.productName);
       console.log(values.productName);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var checkByHash = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.picHash);
       console.log(values.picHash);

        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

exports.quantityInfo = quantityInfo;
exports.checkByHash = checkByHash;