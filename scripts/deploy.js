const { ethers } = require("hardhat");
const hre = require("hardhat");
const { Wallet } = require('ethers');
const Web3 = require("web3");

const phrase = "tonight bargain shallow length river another dry decade loan enter absent culture";

async function main() {
    // We get the contract to deploy
    const provider = new Web3.providers.HttpProvider("http://localhost:9933");
    const web3 = new Web3(provider);

    const walletMnemonic = Wallet.fromMnemonic(phrase);

    const providerEthers = new ethers.providers.JsonRpcProvider(`http://localhost:9933`);
    const signer = new ethers.Wallet(walletMnemonic.privateKey, providerEthers )

    console.log("wallet = ", signer.address);
    console.log("Wallet balance: ", (await signer.getBalance()).toString());
    console.log("Alice balance: ", (await web3.eth.getBalance("0xd43593c715fdd31c61141abd04a99fd6822c8558")).toString());

    const FactoryERC20 = await ethers.getContractFactory("MockToken", signer);
    const erc20 = await FactoryERC20.deploy("Mock Token", "MT", ethers.utils.parseEther("10000"));
    await erc20.deployed();

    const Factory = await ethers.getContractFactory("TradeRegistratorERC20Test", signer);
    const contract = await Factory.deploy();
    await contract.deployed();

    console.log("Wallet balance after: ", (await signer.getBalance()).toString());

    console.log("Contract deployed to:", contract.address);

    console.log("lockTime = ", (await contract.lockTime()).toString());

    let tx = await erc20.connect(signer).approve(contract.address, ethers.utils.parseEther("1"));
    await tx.wait();

    tx = await contract.lock(
      "0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb",
      ethers.utils.parseEther("1"),
      erc20.address,
      "0xd43593c715fdd31c61141abd04a99fd6822c8558",
      ethers.utils.parseEther("0.0001")
    );

    await tx.wait();

    console.log(await contract.transfers("0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb"));
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  