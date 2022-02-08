const hre = require("hardhat");
const { waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { constants } = require('@openzeppelin/test-helpers');
const { ZERO_ADDRESS } = constants;

const TOTAL_SUPPLY = ethers.utils.parseEther('1000000000');

module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy, save} = deployments;
  const {deployer} = await getNamedAccounts();

  const accounts = waffle.provider.getWallets();
  const owner = accounts[0];

  // ------------------- TOKENS DEPLOYMENTS -----------------------

  // let mockXBE = await deploy('MockToken', {
  //   from: owner.address,
  //   args: ['MockXBE', 'XBE', TOTAL_SUPPLY],
  //   log: true,
  // });
  // await save('MockXBE', mockXBE);

  
};
module.exports.tags = ['deploy_mock_vaults'];
