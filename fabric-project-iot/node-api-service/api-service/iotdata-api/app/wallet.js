'use strict';

var log4js = require('log4js');
var logger = log4js.getLogger(process.env.LOGGER_LABEL);

const { FileSystemWallet } = require('fabric-network');
const path = require('path');

const walletPath = path.join(__dirname, '..', '..', 'wallet');
const wallet = new FileSystemWallet(walletPath);

class Wallet {
    
    //返回一個wallet物件
    wallet() { return wallet }

    //判斷wallet是否存在
    async notExist(usr){
        const userExists = await wallet.exists(usr);
        if (!userExists) {
            logger.error("pid " + process.pid + `:: An identity for the user '${usr}' does not exist in the wallet`);
            return;
        }
    }

}

module.exports = Wallet;
