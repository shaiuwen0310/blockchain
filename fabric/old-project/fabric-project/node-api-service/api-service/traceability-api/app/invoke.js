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

var setInfo = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.productName, values.produceDate, values.operateDate, values.productQuantity, values.account, values.picHash, values.imgName);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }

}

var verifyInfo = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.txid, values.trackingNumber, values.productToken);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }

}

var delInfo = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {

    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.productName, values.produceDate, values.operateDate);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }

}

exports.setInfo = setInfo;
exports.verifyInfo = verifyInfo;
exports.delInfo = delInfo;
