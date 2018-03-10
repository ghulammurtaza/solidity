const hdWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const {interface, bytecode} =  require('./compile');

const provider = new hdWalletProvider (
  'tool napkin salad vacuum task brother squeeze skirt audit leisure museum smoke',
  'https://rinkeby.infura.io/P3P9djvhIuFJQ68Wobtb'
)

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log("Deploying contract from account ", accounts[0]);

  const result = await new web3.eth.Contract(JSON.parse(interface))
                 .deploy({data: bytecode, arguments: ['100', 'stt','stt']})
                 .send({gas: '4712388', from: accounts[0]});
  console.log("deploed at ", result.options.address);
}

deploy();
