import {createAlchemyWeb3} from "@alch/alchemy-web3";
import * as path from "path";
import {Bytes32Ty} from "hardhat/internal/hardhat-network/stack-traces/logger";
import {ethers as eth1} from "ethers";

const {ethers, upgrades} = require("hardhat");
const hardhatConfig = require("../../../hardhat.config");

class GenerativeProjectData {

    network: string;
    senderPublicKey: string;
    senderPrivateKey: string;

    constructor(network: any, senderPrivateKey: any, senderPublicKey: any) {
        this.network = network;
        this.senderPrivateKey = senderPrivateKey;
        this.senderPublicKey = senderPublicKey;
    }

    async deployUpgradeable(adminAddress: any,
                            paramAdd: any,
                            generativeProjectAdd: any
    ) {
        /*if (this.network == "local") {
            console.log("not run local");
            return;
        }*/

        const contract = await ethers.getContractFactory("GenerativeProjectData");
        console.log("GenerativeProjectData.deploying ...")
        const proxy = await upgrades.deployProxy(contract, [adminAddress, paramAdd, generativeProjectAdd], {
            initializer: 'initialize(address, address, address)',
        });
        await proxy.deployed();
        console.log("GenerativeProjectData deployed at proxy:", proxy.address);
        return proxy.address;
    }

    getContract(contractAddress: any, contractName: any = "./artifacts/contracts/data/GenerativeProjectData.sol/GenerativeProjectData.json") {
        console.log("Network run", this.network, hardhatConfig.networks[this.network].url);
        // if (this.network == "local") {
        //     console.log("not run local");
        //     return;
        // }
        let API_URL: any;
        API_URL = hardhatConfig.networks[hardhatConfig.defaultNetwork].url;

        // load contract
        let contract = require(path.resolve(contractName));
        const web3 = createAlchemyWeb3(API_URL)
        const nftContract = new web3.eth.Contract(contract.abi, contractAddress)
        return {web3, nftContract};
    }

    async upgradeContract(proxyAddress: any) {
        const contractUpdated = await ethers.getContractFactory("GenerativeProjectData");
        console.log('Upgrading GenerativeProjectData... by proxy ' + proxyAddress);
        const tx = await upgrades.upgradeProxy(proxyAddress, contractUpdated);
        console.log('GenerativeProjectData upgraded on tx address ' + tx.address);
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

    async getTraitsAvailableValues(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.getTraitsAvailableValues().call(tx);
        return val;
    }

    async tokenHTML(contractAddress: any, projectId: any, tokenId: any, seed: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.tokenHTML(projectId, tokenId, seed).call(tx);
        return val;
    }

    async tokenURI(contractAddress: any, projectId: any, tokenId: any, seed: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.tokenURI(projectId, tokenId, seed).call(tx);
        return val;
    }

    async tokenBaseURI(contractAddress: any, projectId: any, tokenId: any, seed: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.tokenBaseURI(projectId, tokenId, seed).call(tx);
        return val;
    }

    async inflateScript(contractAddress: any, script: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.inflateScript(script).call(tx);
        return val;
    }

    async changeProjectAddress(contractAddress: any, newAddr: any, gas: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        const fun = temp?.nftContract.methods.changeProjectAddress(newAddr)
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

    async changeBfs(contractAddress: any, newAddr: any, gas: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        const fun = temp?.nftContract.methods.changeBfs(newAddr)
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

    async getChainID(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.getChainID().call(tx);
        return val;
    }
}

export {GenerativeProjectData};