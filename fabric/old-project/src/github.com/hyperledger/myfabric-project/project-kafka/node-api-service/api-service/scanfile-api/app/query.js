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

var checkByTxid = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.txid);
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

        const result = await contract.evaluateTransaction(chaincodeFunction, values.hash);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var checkBySerialNum = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.serialnumber);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var checkBySerialNumBlockId = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.serialnumber, values.blockid);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var getHistoryByHash = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.hash);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

exports.checkByTxid = checkByTxid;
exports.checkByHash = checkByHash;
exports.checkBySerialNum = checkBySerialNum;
exports.getHistoryByHash = getHistoryByHash;
exports.checkBySerialNumBlockId = checkBySerialNumBlockId;