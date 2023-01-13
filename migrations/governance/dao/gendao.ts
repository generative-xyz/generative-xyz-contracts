import {createAlchemyWeb3} from "@alch/alchemy-web3";
import * as path from "path";
import {Bytes32Ty} from "hardhat/internal/hardhat-network/stack-traces/logger";
import {ethers as eth1} from "ethers";

const {ethers, upgrades} = require("hardhat");
const hardhatConfig = require("../../../hardhat.config");

class GenDAO {
    network: string;
    senderPublicKey: string;
    senderPrivateKey: string;

    constructor(network: any, senderPrivateKey: any, senderPublicKey: any) {
        this.network = network;
        this.senderPrivateKey = senderPrivateKey;
        this.senderPublicKey = senderPublicKey;
    }

    async deployUpgradeable(name: string,
                            adminAddress: any,
                            paramAdd: any,
                            votingToken: any,
                            timelock: any
    ) {
        if (this.network == "local") {
            console.log("not run local");
            return;
        }

        const contract = await ethers.getContractFactory("GenDAO");
        console.log("GenDAO.deploying ...")
        const proxy = await upgrades.deployProxy(contract, [name, adminAddress, paramAdd, votingToken, timelock], {
            initializer: 'initialize(string, address, address, address, address)',
        });
        await proxy.deployed();
        console.log("GenDAO deployed at proxy:", proxy.address);
        return proxy.address;
    }

    getContract(contractAddress: any, contractName: any = "./artifacts/contracts/governance/GenDAO.sol/GenDAO.json") {
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
        const contractUpdated = await ethers.getContractFactory("GenDAO");
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

    async quorumVotes(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods.quorumVotes().call(tx);
    }

    async proposalThreshold(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods.proposalThreshold().call(tx);
    }

    async votingPeriod(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods.votingPeriod().call(tx);
    }

    async votingDelay(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods.votingDelay().call(tx);
    }

    async _admin(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods._admin().call(tx);
    }

    async _votingToken(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods._votingToken().call(tx);
    }

    async _paramAddr(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods._paramAddr().call(tx);
    }

    async changeProposalThreshold(contract: any, threshold: any, gas: number) {
        let temp = this.getContract(contract);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        const fun = temp?.nftContract.methods.changeProposalThreshold(threshold);
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contract,
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

export {GenDAO}