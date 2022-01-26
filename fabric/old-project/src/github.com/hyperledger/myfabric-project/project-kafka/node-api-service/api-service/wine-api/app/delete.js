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

var deleteRecordBYKey = async function(channelName, chaincodeName, userName, fcn, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, fcn, values);
        const contract = await getcontract.getContract();

        // Submit the specified transaction.
        await contract.submitTransaction(fcn, values);
        console.log('Transaction has been submitted');

        // Disconnect from the gateway.
        getcontract.disConnect();

        return "delete OK"

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

exports.deleteRecordBYKey = deleteRecordBYKey;
