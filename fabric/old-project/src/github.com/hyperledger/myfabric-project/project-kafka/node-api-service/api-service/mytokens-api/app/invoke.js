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

var newToken = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.tokenname, values.symbol, values.value, values.total, values.tokenaccount, values.corporation, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var activateToken = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.tokenname, values.tokenaccount, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var freezenToken = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.tokenname, values.tokenaccount, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var deleteToken = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.tokenname, values.tokenaccount, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var newMember = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.membername, values.account, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var activateMember = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.account, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var freezenMember = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.account, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var approveOfGiven = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.myaccount, values.hisaccount, values.value, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var CoinBaseAndMemberTxn = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.tokenname, values.tokenaccount, values.memberaccount, values.counts, values.walletid, values.choose);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var Member1ToMember2 = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.tokenname, values.memberfromaccount, values.membertoaccount, values.counts, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

var TokenExchangeToken = async function(channelName, chaincodeName, userName, chaincodeFunction, values) {
    try {

        if (! wt.notExist(userName)){ return wt.notExist(userName) }

        const getcontract = new GetContract(channelName, chaincodeName, userName, wallet, ccp, chaincodeFunction, values);
        const contract = await getcontract.getContract();

        const result = await contract.submitTransaction(chaincodeFunction, values.memberacc, values.holdingtoken, values.holdingtokenacc, values.holdingtokennumber, values.exchangetoken, values.exchangetokenacc, values.walletid);
        console.log('Transaction has been submitted');

        getcontract.disConnect();

        return result;

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

exports.newToken = newToken;
exports.activateToken = activateToken;
exports.freezenToken = freezenToken;
exports.deleteToken = deleteToken;
exports.newMember = newMember;
exports.activateMember = activateMember;
exports.freezenMember = freezenMember;
exports.approveOfGiven = approveOfGiven;
exports.CoinBaseAndMemberTxn = CoinBaseAndMemberTxn;
exports.Member1ToMember2 = Member1ToMember2;
exports.TokenExchangeToken = TokenExchangeToken;