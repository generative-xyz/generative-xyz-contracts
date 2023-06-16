import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeProject} from "../generativeProject/generativeProject";
import * as fs from "fs";
import {base64} from "ethers/lib.esm/utils";
import {Soul} from "./soul";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const tokenId = args[1];

        const nft = new Soul(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        a.getTokenURI = await nft.getTokenURI(contract, tokenId);
        fs.writeFileSync('./migrations/nfts/soul/1.json', a.getTokenURI);
        // a._reservations = await nft._reservations(contract, tokenId, process.env.PUBLIC_KEY);
        // a.p5jsScript = await nft.p5jsScript(contract);
        // a.web3Script = await nft.web3Script(contract);
        // a._script = await nft._script(contract);
        // a._signerMint = await nft._signerMint(contract);
        // console.log('_signerMint', a._signerMint);
        // a.getMessageHash = await nft.getMessageHash(contract, "0xF61234046A18b07Bf1486823369B22eFd2C4507F", '0');
        // console.log('getMessageHash', a.getMessageHash);
        // a.available = await nft.available(contract, tokenId);
        // console.log('available', a.available);
        // a.biddable = await nft.biddable(contract, tokenId);
        // console.log('biddable', a.biddable);


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