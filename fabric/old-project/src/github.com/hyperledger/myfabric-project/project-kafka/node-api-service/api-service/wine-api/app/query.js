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

var queryWineBYkey = async function(channelName, chaincodeName, usr, fcn, values) {
    try {

        if (! wt.notExist(usr)){ return wt.notExist(usr) }

        const getcontract = new GetContract(channelName, chaincodeName, usr, wallet, ccp, fcn, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(fcn, values);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error.toString()}`);
        process.exit(1);
    }
};

var queryWineHistoryBYkey = async function(channelName, chaincodeName, usr, fcn, values) {
    try {

        if (! wt.notExist(usr)){ return wt.notExist(usr) }

        const getcontract = new GetContract(channelName, chaincodeName, usr, wallet, ccp, fcn, values);
        const contract = await getcontract.getContract();
        
        const result = await contract.evaluateTransaction(fcn, values);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        process.exit(1);
    }
};

var queryWineByPlace = async function(channelName, chaincodeName, usr, fcn, values) {
    try {

        if (! wt.notExist(usr)){ return wt.notExist(usr) }

        const getcontract = new GetContract(channelName, chaincodeName, usr, wallet, ccp, fcn, values);
        const contract = await getcontract.getContract();

        const result = await contract.evaluateTransaction(fcn, values);
        return result

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        process.exit(1);
    }
};

var queryWinesWithPagination = async function(channelName, chaincodeName, usr, fcn, fld, val, page, tag) {
    try {

        if (! wt.notExist(usr)){ return wt.notExist(usr) }

        const getcontract = new GetContract(channelName, chaincodeName, usr, wallet, ccp, fcn, val);
        const contract = await getcontract.getContract();

        // Evaluate the specified transaction.
        const slr = '{"selector":{"' + fld + '":"' + val + '"}}'; // const slr = '{"selector":{"winerymbr":"AAA001"}}';
        const result = await contract.evaluateTransaction(fcn, slr, page, tag);

        return new Promise(resolve => {
            setTimeout(() => resolve(result.toString()), 1000)
        })
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        process.exit(1);
    }
};

exports.queryWineBYkey = queryWineBYkey;
exports.queryWineHistoryBYkey = queryWineHistoryBYkey;
exports.queryWineByPlace = queryWineByPlace;
exports.queryWinesWithPagination = queryWinesWithPagination;