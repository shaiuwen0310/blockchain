
'use strict';

const { FileSystemWallet, X509WalletMixin, Gateway } = require('fabric-network');
const path = require('path');

const walletPath = path.join(__dirname, '..', '..', '..', 'wallet');
const wallet = new FileSystemWallet(walletPath);

class Wallet {
    
    //返回一個wallet物件
    wallet() { return wallet }

    //判斷wallet是否存在
    async notExist(usr){
        const userExists = await wallet.exists(usr);
        if (!userExists) {
            let err = `An identity for the user ${usr} does not exist in the wallet`;
            console.log(err);
            return err;
        }
    }

}

module.exports = Wallet;