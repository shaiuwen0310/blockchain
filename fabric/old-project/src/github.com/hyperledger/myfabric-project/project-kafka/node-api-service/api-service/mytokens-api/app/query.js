/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { FileSystemWallet, Gateway } = require('fabric-network');

const Config = require('./config.js');
const config = new Config();
const ccp = config.netConfig();

const Wallet = require('./wallet.js');
const wt = new Wallet();
const wallet = wt.wallet();

const GetContract = require('./getcontract.js');

var getTokenInfo = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.tokenname);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var getTokenSupplyTotal = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.tokenname);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var getHistoryOfTokenAccount = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.tokenname, values.tokenaccount);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var getApproveOfValue = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.myaccount, values.hisaccount);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var getMemberBalance = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.memberaccount);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var getHistoryOfAccount = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(chaincodeFunction, values.memberaccount);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

exports.getTokenInfo = getTokenInfo;
exports.getTokenSupplyTotal = getTokenSupplyTotal;
exports.getHistoryOfTokenAccount = getHistoryOfTokenAccount;
exports.getApproveOfValue = getApproveOfValue;
exports.getMemberBalance = getMemberBalance;
exports.getHistoryOfAccount = getHistoryOfAccount