import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeProject} from "../generativeProject/generativeProject";
import {GenerativeNFTUpgradeable} from "./GenerativeNFT";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contractPro = args[0];
        const project = new GenerativeProject(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        a.parent = await project.projectDetails(contractPro, args[1]);

        const nft = new GenerativeNFTUpgradeable(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        a.project = await nft.getProject(a.parent._genNFTAddr);
        console.log(a.project);
        
        for (let i = 0; i < 1; i++) {
            const tx = await nft.mint(a.parent._genNFTAddr, a.project._mintPrice, process.env.PUBLIC_KEY, ["0x1"], 0);
            console.log("tx: ", tx?.transactionHash, tx?.status);
        }
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();