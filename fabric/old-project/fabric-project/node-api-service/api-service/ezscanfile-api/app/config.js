
'use strict';

const fs = require('fs');
const yaml = require('js-yaml');
const path = require('path');

const ccpPath = path.resolve(__dirname, '..', '..', '..', 'gateway', 'networkConnection.yaml');
const ccpJSON = fs.readFileSync(ccpPath, 'utf8');
const ccp = yaml.safeLoad(ccpJSON);

class Config {

    netConfig() { return ccp }

}

module.exports = Config;