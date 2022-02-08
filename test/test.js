const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');

const TOTALSUPPLY = ethers.utils.parseEther('1000000000');           // <- 1 billion * 10^18

const ONE = BigNumber.from('1');
const TEN = BigNumber.from('10');
const HUN = BigNumber.from('100');

chai.use(require('chai-bignumber')());


describe("test", function () {
    const accounts = waffle.provider.getWallets();
    const owner = accounts[0];                     
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];

    beforeEach("deploying", async() => {
       
    })


  it("should", async() => {
    
    
    
  });
});
