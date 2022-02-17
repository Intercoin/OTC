const { ethers } = require("hardhat");

async function main() {
    // We get the contract to deploy
    const Factory = await ethers.getContractFactory("TradeRegistratorERC20");
    const contract = await Factory.deploy();
    
    console.log("Contract deployed to:", contract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  