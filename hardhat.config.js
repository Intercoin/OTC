require('dotenv').config()

require("@nomiclabs/hardhat-ethers")
require('hardhat-docgen')
require('hardhat-deploy')
require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-web3")
require("@nomiclabs/hardhat-etherscan")
require("solidity-coverage")
require("hardhat-gas-reporter")


const kovanURL = `https://eth-kovan.alchemyapi.io/v2/${process.env.ALCHEMY_KOVAN}`
const goerliURL = `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_GOERLI}`
const rinkebyURL = `https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_RINKEBY}`
const mainnetURL = `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_MAINNET}`
const bscTestnetURL = `https://data-seed-prebsc-1-s1.binance.org:8545/`
const fantomTestnetURL = "https://rpcapi-tracing.testnet.fantom.network";
const substrateMyTestnetURL = "http://127.0.0.1:9933";


module.exports = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
    },
    kovan: {
      url: kovanURL,
      chainId: 42,
      gas: 12000000,
      accounts: {mnemonic: process.env.MNEMONIC},
      saveDeployments: true
    },
    substrateMyTestnet: {
      url: substrateMyTestnetURL,
      chainId: 42,
      gas: 12000000,
      gasPrice: 0,
      accounts: {mnemonic: process.env.MNEMONIC_SUBSTRATE},
      saveDeployments: true
    },
    goerli: {
      url: goerliURL,
      chainId: 5,
      gasPrice: 1000,
      accounts: {mnemonic: process.env.MNEMONIC},
      saveDeployments: true
    },
    rinkeby: {
      url: rinkebyURL,
      chainId: 4,
      gasPrice: "auto",
      accounts: {mnemonic: process.env.MNEMONIC},
      saveDeployments: true
    },
    mainnet: {
      url: mainnetURL,
      chainId: 1,
      gasPrice: 20000000000,
      accounts: {mnemonic: process.env.MNEMONIC},
      saveDeployments: true
    },
    bscTestnet: {
      url: bscTestnetURL,
      chainId: 97,
      gasPrice: 20000000000,
      accounts: {mnemonic: process.env.MNEMONIC},
      saveDeployments: true
    },
    fantom_testnet: {
      url: fantomTestnetURL,
      chainId: 0xfa2,
      gasPrice: 200000000000,
      accounts: {mnemonic: process.env.MNEMONIC},
      saveDeployments: true,
      skipIfAlreadyDeployed: true
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD"
  },
  etherscan: {
    apiKey: {
      bscTestnet: process.env.BSCSCAN_API_KEY,
      rinkeby: process.env.ETHERSCAN_API_KEY,
    }
  },
  solidity: {
    compilers: [
        {
          version: "0.8.11",
          settings: {
            optimizer: {
              enabled: false,
              runs: 200,
            },
            metadata: {
              // do not include the metadata hash, since this is machine dependent
              // and we want all generated code to be deterministic
              // https://docs.soliditylang.org/en/v0.7.6/metadata.html
              bytecodeHash: "none",
            },
          },
        },
        {
          version: "0.6.7",
          settings: {},
          settings: {
            optimizer: {
              enabled: false,
              runs: 200,
            },
            metadata: {
              // do not include the metadata hash, since this is machine dependent
              // and we want all generated code to be deterministic
              // https://docs.soliditylang.org/en/v0.7.6/metadata.html
              bytecodeHash: "none",
            },
          },
        },
      ],
  
    
  },

  namedAccounts: {
    deployer: 0,
    },

  paths: {
    sources: "contracts",
  },
  gasReporter: {
    currency: 'USD',
    enabled: (process.env.REPORT_GAS === "true") ? true : false
  },
  mocha: {
    timeout: 50000000
  }
}
