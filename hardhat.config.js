/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("hardhat-gas-reporter");
require('hardhat-contract-sizer');
require("@nomiclabs/hardhat-etherscan");
require('@openzeppelin/hardhat-upgrades');
var verify = require("@ericxstone/hardhat-blockscout-verify");

module.exports = {
    solidity: {
        version: "0.8.12",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    defaultNetwork: process.env.NETWORK,
    etherscan: {
        apiKey: process.env.ETHSCAN_API_KEY,
        customChains: [
            {
                network: "tc_mainnet",
                chainId: 22213,
                urls: {
                    apiURL: "https://explorer.trustless.computer/api",
                    browserURL: "https://explorer.trustless.computer/api"
                }
            },
            {
                network: "tc_testnet",
                chainId: 22215,
                urls: {
                    apiURL: "https://explorer.regtest.trustless.computer/api",
                    browserURL: "https://explorer.regtest.trustless.computer/api"
                }
            }
        ]
    },
    networks: {
        hardhat: {
            allowUnlimitedContractSize: true,
        },
        local: {
            url: process.env.LOCAL_API_URL,
            accounts: [
                `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`,
            ],
        },
        rinkeby: {
            url: process.env.RINKEBY_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        goerli: {
            url: process.env.GOERLI_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        ropsten: {
            url: process.env.ROPSTEN_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
            gas: 500000,
        },
        mainnet: {
            url: process.env.MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        polygon: {
            url: process.env.POLYGON_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        mumbai: {
            url: process.env.POLYGON_MUMBAI_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        fantom: {
            url: process.env.FANTOM_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        fantom_testnet: {
            url: process.env.FANTOM_TESTNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        harmony: {
            url: process.env.HARMONY_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        harmony_testnet: {
            url: process.env.HARMONY_TESTNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        kardia: {
            url: process.env.KARDIA_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        kardia_testnet: {
            url: process.env.KARDIA_TESTNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        aurora: {
            url: process.env.AURORA_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        aurora_testnet: {
            url: process.env.AURORA_TESTNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        bsc_mainnet: {
            url: process.env.BSC_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        bsc_testnet: {
            url: process.env.BSC_TESTNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        tc_testnet: {
            url: process.env.TC_TESTNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        tc_mainnet: {
            url: process.env.TC_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
            timeout: 100_000,
        }
    },
    mocha: {
        timeout: 40000000,
    },
    blockscoutVerify: {
        blockscoutURL: "https://explorer.regtest.trustless.computer/api",
        contracts: {
            "SOUL": {
                compilerVersion: verify.SOLIDITY_VERSION.SOLIDITY_V_8_12,
                optimization: false,
                evmVersion: verify.EVM_VERSION.EVM_BERLIN,
                optimizationRuns: 200,
            },
        }
    }
};