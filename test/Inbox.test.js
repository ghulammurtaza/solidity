const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3'); //web3 require needs to call through constructor function
const web3 = new Web3(ganache.provider());

let accounts;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts()

});

describe('Inbox', () => {
  it('deploys a new contract', () => {
    console.log(accounts);
  });
});
