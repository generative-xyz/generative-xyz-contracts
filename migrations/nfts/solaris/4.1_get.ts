import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeProject} from "../generativeProject/generativeProject";
import {Solaris} from "./Solaris";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const tokenId = args[1];

        const nft = new Solaris(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        // a.getTokenURI = await nft.getTokenURI(contract, tokenId);
        // a._reservations = await nft._reservations(contract, tokenId, process.env.PUBLIC_KEY);
        a.p5jsScript = await nft.p5jsScript(contract);
        a.web3Script = await nft.web3Script(contract);
        a.tokenHTML = await nft.tokenHTML(contract, "");
        console.log({a});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();