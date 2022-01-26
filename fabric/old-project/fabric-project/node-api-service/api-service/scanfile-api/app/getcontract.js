
'use strict';

const { FileSystemWallet, X509WalletMixin, Gateway } = require('fabric-network');
const gateway = new Gateway();

class GetContract {
    constructor(channelName, chaincodeName, usr, wallet, ccp, fcn, values){
        this.channelName = channelName
        this.chaincodeName = chaincodeName
        this.usr = usr
        this.wallet = wallet
        this.ccp = ccp
        this.fcn = fcn
        this.values = values
    }

    async getContract(){
        // Create a new gateway for connecting to our peer node.

        let connectionOptions = {
            identity: this.usr,
            wallet: this.wallet,
            discovery: { enabled:false }
        };

        await gateway.connect(this.ccp, connectionOptions);

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(this.channelName);

        // Get the contract from the network.
        const contract = network.getContract(this.chaincodeName);
        return contract;
    }

    async disConnect(){
        await gateway.disconnect();
    }
}

module.exports = GetContract;