import Web3 from 'web3';

const web3 = new Web3(window.web3.currentProvider); //taking metamask web3 provider and inject into local web3

export default web3;
