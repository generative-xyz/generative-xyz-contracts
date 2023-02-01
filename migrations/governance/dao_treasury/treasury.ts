import {createAlchemyWeb3} from "@alch/alchemy-web3";
import * as path from "path";
import {Bytes32Ty} from "hardhat/internal/hardhat-network/stack-traces/logger";
import {ethers as eth1} from "ethers";

const {ethers, upgrades} = require("hardhat");
const hardhatConfig = require("../../../hardhat.config");

class Treasury {
    network: string;
    senderPublicKey: string;
    senderPrivateKey: string;

    constructor(network: any, senderPrivateKey: any, senderPublicKey: any) {
        this.network = network;
        this.senderPrivateKey = senderPrivateKey;
        this.senderPublicKey = senderPublicKey;
    }

    async deployUpgradeable(
        adminAddress: any,
        paramAdd: any,
        dao: any,
    ) {
        if (this.network == "local") {
            console.log("not run local");
            return;
        }

        const contract = await ethers.getContractFactory("GenDAOTreasury");
        console.log("GenDAOTreasury.deploying ...")
        const proxy = await upgrades.deployProxy(contract, [adminAddress, paramAdd, dao], {
            initializer: 'initialize(address, address, address)',
        });
        await proxy.deployed();
        console.log("GenDAOTreasury deployed at proxy:", proxy.address);
        return proxy.address;
    }

    getContract(contractAddress: any, contractName: any = "./artifacts/contracts/governance/GenDAOTreasury.sol/GenDAOTreasury.json") {
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
        const contractUpdated = await ethers.getContractFactory("GenDAOTreasury");
        console.log('Upgrading GenDAOTreasury... by proxy ' + proxyAddress);
        const tx = await upgrades.upgradeProxy(proxyAddress, contractUpdated);
        console.log('GenDAOTreasury upgraded on tx address ' + tx.address);
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

    async withdraw(contract: any, erc20: any, amount: any, gas: number) {
        let temp = this.getContract(contract);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        const fun = temp?.nftContract.methods.withdraw(erc20, ethers.utils.parseEther(amount));
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

    async withdrawERC721(contract: any, erc721: any, tokenId: any, gas: number) {
        let temp = this.getContract(contract);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        const fun = temp?.nftContract.methods.withdrawERC721(erc721, parseInt(tokenId));
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

    async withdrawERC1155(contract: any, erc1155: any, tokenId: any, amount: any, gas: number) {
        let temp = this.getContract(contract);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        const fun = temp?.nftContract.methods.withdrawERC1155(erc1155, parseInt(tokenId), amount);
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

export {Treasury};