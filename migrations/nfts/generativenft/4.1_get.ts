import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeNFT} from "./GenerativeNFT";
import {GenerativeProject} from "../generativeProject/generativeProject";

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

        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        a.project = await nft.getProject(a.parent._genNFTAddr);
        console.log(a.project);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();