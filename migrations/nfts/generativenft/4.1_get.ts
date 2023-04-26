import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeNFT} from "./GenerativeNFT";
import {GenerativeProject} from "../generativeProject/generativeProject";

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

        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        // a.project = await nft.getProject(a.parent._genNFTAddr);
        // a.royalty = await nft.royalty(a.parent._genNFTAddr);
        // a.randomizer = await nft.randomizerAddr(a.parent._genNFTAddr);
        // a.randomizer = await nft.randomizerAddr(a.parent._genNFTAddr);
        // a.tokenIdToHash = await nft.tokenIdToHash(a.parent._genNFTAddr, parseInt(args[1]) * 1e6 + parseInt(args[2]));
        // console.log("a.parent._genNFTAddr", a.parent._genNFTAddr)
        // a.tokenURI = await nft.getTokenURI(a.parent._genNFTAddr, parseInt(args[1]) * 1e6 + parseInt(args[2]));
        // a.fileNames = await nft.fileNames(a.parent._genNFTAddr, parseInt(args[1]) * 1e6 + parseInt(args[2]));
        // a.tokenGenerativeURI = await nft.getTokenGenerativeURI(a.parent._genNFTAddr, parseInt(args[1]) * 1e6 + parseInt(args[2]));
        // a.projectIndex = await nft.projectIndex(a.parent._genNFTAddr);
        a.royaltyInfo = await nft.royaltyInfo(a.parent._genNFTAddr, parseInt(args[1]) * 1e6 + parseInt(args[2]), args[3]);
        console.log(a.royaltyInfo);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();