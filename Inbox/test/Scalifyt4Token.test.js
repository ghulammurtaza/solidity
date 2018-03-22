const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3'); //web3 require needs to call through constructor function
const web3 = new Web3(ganache.provider());
const {interface, bytecode} = require('../compile');

let accounts;
let inbox

beforeEach(async () => {
  //git list of accounts
  accounts = await web3.eth.getAccounts()

 // use one of the available accounts to deploy contract;
 inbox = await new web3.eth.Contract(JSON.parse(interface))
     .deploy({'data': bytecode, 'arguments': []})
     .send({'from': accounts[0], 'gas' : 3000000});
});

describe('Scalifyt4Token', () => {
  //make sure contract has been deployed
  it('deploys a new contract', () => {
    assert.ok(inbox.options.address);
  });

  it('current round index', async () => {
    const  message = await inbox.methods.currentRoundIndexByDate().call();
    console.log(message);
  });


});
