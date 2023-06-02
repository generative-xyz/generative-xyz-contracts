import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeProject} from "../generativeProject/generativeProject";
import * as fs from "fs";
import {Solaris} from "./Solaris";
import {base64} from "ethers/lib.esm/utils";

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
        a.getTokenURI = await nft.getTokenURI(contract, tokenId);
        // a._reservations = await nft._reservations(contract, tokenId, process.env.PUBLIC_KEY);
        // a.p5jsScript = await nft.p5jsScript(contract);
        // a.web3Script = await nft.web3Script(contract);
        // a._script = await nft._script(contract);
        fs.writeFileSync('./index.json', a.getTokenURI);
        /*a.tokenIdToHash = await nft.tokenIdToHash(contract, tokenId)
        a.tokenHTML = await nft.tokenHTML(contract, a.tokenIdToHash, tokenId);
        if (a.tokenHTML) {
            try {
                fs.writeFileSync('./index.html', a.tokenHTML);
                // file written successfully
            } catch (err) {
                console.error(err);
            }
        }*/
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();