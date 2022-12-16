import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import {GenerativeNFT} from "./GenerativeNFT";
import {GenerativeProject} from "../generativeProject/generativeProject";

(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2)

        const contractPro = args[0];
        const project = new GenerativeProject(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        a.parent = await project.projectDetails(contractPro, args[1]);

        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await nft.changeDataContextAddr(a.parent._genNFTAddr, args[2], 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();