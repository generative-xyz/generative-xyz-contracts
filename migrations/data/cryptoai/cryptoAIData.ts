import {createAlchemyWeb3} from "@alch/alchemy-web3";
import * as path from "path";
import {DNA} from "./data";

const {ethers, upgrades} = require("hardhat");
const hardhatConfig = require("../../../hardhat.config");

class CryptoAIData {
    network: string;
    senderPublicKey: string;
    senderPrivateKey: string;

    constructor(network: any, senderPrivateKey: any, senderPublicKey: any) {
        this.network = network;
        this.senderPrivateKey = senderPrivateKey;
        this.senderPublicKey = senderPublicKey;

        console.log("senderPrivateKey", senderPrivateKey);
        console.log("senderPublicKey", senderPublicKey);
    }

    async deployUpgradeable(deployerAddr: any
    ) {
        // if (this.network == "local") {
        //     console.log("not run local");
        //     return;
        // }

        const contract = await ethers.getContractFactory("CryptoAIData");
        console.log("CryptoAIData.deploying ...")
        const proxy = await upgrades.deployProxy(contract, [deployerAddr], {
            initializer: 'initialize(address)',
        });
        await proxy.deployed();
        console.log("CryptoAIData deployed at proxy:", proxy.address);
        return proxy.address;
    }

    getContract(contractAddress: any, contractName: any = "./artifacts/contracts/data/CryptoAIData.sol/CryptoAIData.json") {
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
        const contractUpdated = await ethers.getContractFactory("CryptoAIData");
        console.log('Upgrading CryptoAIData... by proxy ' + proxyAddress);
        const tx = await upgrades.upgradeProxy(proxyAddress, contractUpdated);
        console.log('CryptoAIData upgraded on tx address ' + await tx.address);
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

    async addItem(contractAddress: any, gas: any, key: string, name: string[], trait: number[], positions: number[][]) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.addItem(key, name, trait, positions)
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

    async getDeployer(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods._deployer().call(tx);
        return val;
    }

    async getItem(contractAddress: any, _itemType: string) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.getItem(_itemType).call(tx);
        return val;
    }

    async addDNA(contractAddress: any, gas: any, dna: string[], trait: number[]) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce


        const fun = temp?.nftContract.methods.addDNA(dna, trait)
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

    async addDNAVariant(contractAddress: any, gas: any, key: DNA, name: string[],
                        trait: number[],
                        positions: number[][]) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce


        const fun = temp?.nftContract.methods.addDNAVariant(key, name, trait, positions);
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

    async addDNAVariantRobot(contractAddress: any, gas: any, name: string[],
                             trait: number[]) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce


        const fun = temp?.nftContract.methods.addDNAVariantRobot(name, trait);
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

    async addDNAVariantRobotPosition(contractAddress: any, gas: any, positions: number[][], index: number, length: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        const fun = temp?.nftContract.methods.addDNAVariantRobotPosition(positions, index, length);
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }
        console.log(positions.length, index, length);
        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }
        return await this.signedAndSendTx(temp?.web3, tx);
    }

    async setPalettes(contractAddress: any, gas: any, palettes: number[][]) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce


        const fun = temp?.nftContract.methods.setPalettes(palettes);
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

    async getDNAVariant(contractAddress: any, index: number, key: DNA) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.getDNAVariant(key, index).call(tx);
        return val;
    }

    async getDNA(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.getDNA().call(tx);
        return val;
    }

    async cryptoAIImageSvg(contractAddress: any, token: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.cryptoAIImageSvg(token).call(tx);
        return val;
    }

    async cryptoAIImage(contractAddress: any, token: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.cryptoAIImage(token).call(tx);
        return val;
    }

    async cryptoAIImageHtml(contractAddress: any, token: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.cryptoAIImageHtml(token).call(tx);
        return val;
    }

    async cryptoAIAttributes(contractAddress: any, token: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.cryptoAIAttributes(token).call(tx);
        return val;
    }

    async cryptoAIAttributesValue(contractAddress: any, token: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.cryptoAIAttributesValue(token).call(tx);
        return val;
    }

    async tokenURI(contractAddress: any, token: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.tokenURI(token).call(tx);
        return val;
    }

    async changeCryptoAIAgentAddress(contractAddress: any, gas: any, newAddr: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.changeCryptoAIAgentAddress(newAddr)
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

    async changePlaceHolderScript(contractAddress: any, gas: any, placeHolderScript: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.changePlaceHolderScript(placeHolderScript)
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

    async changePlaceHolderImg(contractAddress: any, gas: any, placeHolderScript: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.changePlaceHolderImg(placeHolderScript)
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

    async mintAgent(contractAddress: any, gas: any, tokenId: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.mintAgent(tokenId)
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

    async unlockRenderAgent(contractAddress: any, gas: any, tokenId: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.unlockRenderAgent(tokenId)
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

    async sealContract(contractAddress: any, gas: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.sealContract()
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

    async unsealContract(contractAddress: any, gas: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.unSealContract()
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

export {CryptoAIData};