const path = require('path');
const fs = require('fs');
const solc = require('solc');

const inboxPath = path.resolve(__dirname, 'contracts', 'ScalifyTestTokenERC20.sol');
console.log(inboxPath);
//const source = fs.readFileSync(inboxPath, 'utf8');

//module.exports = solc.compile(source, 1).contracts[':ScalifyTestTokenERC20'];
