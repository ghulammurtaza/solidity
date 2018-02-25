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
     .deploy({'data': bytecode, 'arguments': ['Hi there']})
     .send({'from': accounts[0], 'gas' : 1000000});
});

describe('Inbox', () => {
  //make sure contract has been deployed
  it('deploys a new contract', () => {
    assert.ok(inbox.options.address);
  });

  it('has a default function', async () => {
    const  message = await inbox.methods.message().call();
    assert.equal(message, 'Hi there');
  });

  it('can change the message', async () => {
    await inbox.methods.setMessage('loving it').send({from:accounts[0]});
    const message = await inbox.methods.message().call();
    assert.equal(message, 'loving it');

  })
});
