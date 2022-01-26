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

var setContent = async function(channelName, chaincodeName, userName, chaincodeFunction, values, key) {
    try {

        console.log(values.uuid)

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, key, values);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

exports.setContent = setContent;