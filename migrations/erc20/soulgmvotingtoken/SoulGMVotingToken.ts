import {createAlchemyWeb3} from "@alch/alchemy-web3";
import * as path from "path";
import {Bytes32Ty} from "hardhat/internal/hardhat-network/stack-traces/logger";
import {ethers as eth1} from "ethers";

const {ethers, upgrades} = require("hardhat");
const hardhatConfig = require("../../../hardhat.config.js");

class SoulGMVotingToken {
    network: string;
    senderPublicKey: string;
    senderPrivateKey: string;

    constructor(network: any, senderPrivateKey: any, senderPublicKey: any) {
        this.network = network;
        this.senderPrivateKey = senderPrivateKey;
        this.senderPublicKey = senderPublicKey;
    }

    async deployUpgradeable(name: string, symbol: string, admin: any, param: any, gmToken: any) {
        if (this.network == "local") {
            console.log("not run local");
            return;
        }

        const contract = await ethers.getContractFactory("SOULGMVotesCompToken");
        console.log("SOULGMVotesCompToken.deploying ...")
        const proxy = await upgrades.deployProxy(contract, [name, symbol, admin, param, gmToken], {
            initializer: 'initialize(string, string, address, address, address)',
        });
        await proxy.deployed();
        console.log("SOULGMVotesCompToken deployed at proxy:", proxy.address);
        return proxy.address;
    }

    getContract(contractAddress: any, contractName: any = "./artifacts/contracts/erc20/SOULGMVotesCompToken.sol/SOULGMVotesCompToken.json") {
        console.log("Network run", this.network, hardhatConfig.networks[this.network].url);
        if (this.network == "local") {
            console.log("not run local");
            return;
        }
        let API_URL: any;
        API_URL = hardhatConfig.networks[hardhatConfig.defaultNetwork].url;

        // load contract
        let contract = require(path.resolve(contractName));
        const web3 = createAlchemyWeb3(API_URL)
        const nftContract = new web3.eth.Contract(contract.abi, contractAddress)
        return {web3, nftContract};
    }

    async upgradeContract(proxyAddress: any) {
        const contractUpdated = await ethers.getContractFactory("GENToken");
        console.log('Upgrading GENToken... by proxy ' + proxyAddress);
        const tx = await upgrades.upgradeProxy(proxyAddress, contractUpdated);
        console.log('GENToken upgraded on tx address ' + tx.address);
        return tx;
    }

    async signedAndSendTx(web3: any, tx: any) {
        const signedTx = await web3.eth.accounts.signTransaction(tx, this.senderPrivateKey)
        if (signedTx.rawTransaction != null) {
            let sentTx = await web3.eth.sendSignedTransaction(
                signedTx.rawTransaction,
                function (err: any, hash: any) {
                    if (!err) {
                        console.log(
                            "The hash of your transaction is: ",
                            hash,
                            "\nCheck Alchemy's Mempool to view the status of your transaction!"
                        )
                    } else {
                        console.log(
                            "Something went wrong when submitting your transaction:",
                            err
                        )
                    }
                }
            )
            return sentTx;
        }
        return null;
    }

    async totalSupply(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods.totalSupply().call(tx);
    }

    async balanceOf(contractAddress: any, account: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods.balanceOf(account).call(tx);
    }

    async name(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods.name().call(tx);
    }

    async symbol(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods.symbol().call(tx);
    }

    async mint(contractAddress: any, amount: any, gas: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        const fun = temp?.nftContract.methods.deposit(amount);
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }

        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }

        return await this.signedAndSendTx(temp?.web3, tx);
    }

    async burn(contractAddress: any, amount: any, gas: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        const fun = temp?.nftContract.methods.withdraw(ethers.utils.parseEther(amount));
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }

        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }

        return await this.signedAndSendTx(temp?.web3, tx);
    }

}

export {SoulGMVotingToken};