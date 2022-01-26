/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const FabricCAServices = require('fabric-ca-client');
const { FileSystemWallet, X509WalletMixin, Gateway } = require('fabric-network');

const Config = require('./config.js');
const config = new Config();
const ccp = config.netConfig();

const Wallet = require('./wallet.js');
const wal = new Wallet();
const wallet = wal.wallet();

var enrollAdmin = async function (values) {
    try {

        //ca-org1
        // Create a new CA client for interacting with the CA.
        const caURL = ccp.certificateAuthorities[values.ca].url;
        const ca = new FabricCAServices(caURL);

        // Check to see if we've already enrolled the admin user.
        const adminExists = await wallet.exists(values.enrolled);
        if (adminExists) {
            console.log(`An identity for the admin user already exists in the wallet`);
            return;
        }

        // Enroll the admin user, and import the new identity into the wallet.
        const enrollment = await ca.enroll({ enrollmentID: values.enrolled, enrollmentSecret: values.pwd });
        const identity = X509WalletMixin.createIdentity(values.mspid, enrollment.certificate, enrollment.key.toBytes());
        wallet.import(values.enrolled, identity);
        
        console.log(`Successfully enrolled admin user and imported it into the wallet`);
        console.log(identity);

    } catch (error) {
        console.error(`Failed to enroll admin user: ${error}`);
        process.exit(1);
    }
}

var registerUser = async function(values) {
    try {

        // Check to see if we've already enrolled the user.
        const userExists = await wallet.exists(values.newuser);
        if (userExists) {
            console.log('An identity for the user "abcde" already exists in the wallet');
            return;
        }
        // Check to see if we've already enrolled the admin user.
        const adminExists = await wallet.exists(values.enrolled);
        if (!adminExists) {
            console.log('An identity for the admin user does not exist in the wallet');
            console.log('Run the enrollAdmin application before retrying');
            return;
        }
        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: values.enrolled, discovery: { enabled: false } });
        // Get the CA client object from the gateway for interacting with the CA.
        const ca = gateway.getClient().getCertificateAuthority();
        const adminIdentity = gateway.getCurrentIdentity();
        // Register the user, enroll the user, and import the new identity into the wallet.
        const secret = await ca.register({ affiliation: values.affiliation, enrollmentID: values.newuser, role: values.role }, adminIdentity);
        const enrollment = await ca.enroll({ enrollmentID: values.newuser, enrollmentSecret: secret });
        const userIdentity = X509WalletMixin.createIdentity(values.mspid, enrollment.certificate, enrollment.key.toBytes());
        wallet.import(values.newuser, userIdentity);
        console.log(`Successfully registered and enrolled admin user and imported it into the wallet`);

    } catch (error) {
        console.error(`Failed to register user: ${error}`);
        process.exit(1);
    }
}

exports.enrollAdmin = enrollAdmin;
exports.registerUser = registerUser;


