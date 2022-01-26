/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { FileSystemWallet, Gateway } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const displayfiles = require('./displayfile.js');

const Config = require('./config.js');
const config = new Config();
const ccp = config.netConfig();

const Wallet = require('./wallet.js');
const wt = new Wallet();
const wallet = wt.wallet();

const GetContract = require('./getcontract.js');

var insertOneRecord = async function(channelName, chaincodeName, userName, fcn, args) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, fcn, args);
        const contract = await getcontract.getContract();

        await contract.submitTransaction(fcn, args.name, args.place, args.year, args.winerymbr, args.taste, args.color, args.yield);
        console.log('Transaction has been submitted');

        // Disconnect from the gateway.
        getcontract.disConnect();

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var insertJsonRecord = async function(channelName, chaincodeName, userName, fcn, args) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, fcn, args);
        const contract = await getcontract.getContract();

        //丟object進來後要再轉成string
        const argsStr = JSON.stringify(args);
        await contract.submitTransaction(fcn, argsStr);
        console.log('Transaction has been submitted');

        // Disconnect from the gateway.
        getcontract.disConnect();

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var insertHDFSRecord = async function(channelName, chaincodeName, userName, fcn, args) {
    try {

        //從HDFS下載檔案
        // displayfiles.displayfile('judy/wine1.json');
        displayfiles.displayfile(args);

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, fcn, args);
        const contract = await getcontract.getContract();

        const tmppath = path.join(__dirname, '..', 'tmp');
        const tmpfile = tmppath + "/write.json"
        // Submit the specified transaction.
        var data=fs.readFileSync(tmpfile,"utf-8");
        console.log(typeof(data))
        await contract.submitTransaction(fcn, data.toString());
        console.log('Transaction has been submitted');

        // Disconnect from the gateway.
        getcontract.disConnect();

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

exports.insertOneRecord = insertOneRecord;
exports.insertJsonRecord = insertJsonRecord;
exports.insertHDFSRecord = insertHDFSRecord;