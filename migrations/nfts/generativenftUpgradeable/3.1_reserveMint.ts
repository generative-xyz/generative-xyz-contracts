import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeProject} from "../generativeProject/generativeProject";
import {GenerativeNFTUpgradeable} from "./GenerativeNFT";

(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contractPro = args[0];
        const project = new GenerativeProject(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        a.parent = await project.projectDetails(contractPro, args[1]);

        const nft = new GenerativeNFTUpgradeable(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        for (let i = 0; i < 100; i++) {
            const tx = await nft.reserveMint(a.parent._genNFTAddr, 0, 0);
            console.log("tx: ", i, tx?.transactionHash, tx?.status);
        }
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();