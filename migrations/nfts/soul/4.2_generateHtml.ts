import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeProject} from "../generativeProject/generativeProject";
import * as fs from "fs";
import {base64} from "ethers/lib.esm/utils";
import {Soul} from "./soul";
import {RandomizerService} from "../../services/randomizer/randomizerService";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const randomContract = args[1];
        const tokenId = args[2];
        const dest = args[3];

        const nft = new Soul(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const randomizerService = new RandomizerService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        for (let i = 1; i <= 100; i++) {
            let a: any = {};
            a.tokenIdToHash = await randomizerService.generateTokenHash(randomContract, i);
            console.log("hash", a.tokenIdToHash);
            a.tokenHTML = await nft.tokenHTML(contract, a.tokenIdToHash, tokenId);
            if (a.tokenHTML) {
                try {
                    fs.writeFileSync(dest + i + '.html', a.tokenHTML);
                    console.log("file written successfully", i);
                } catch (err) {
                    console.error(err);
                }
            }
        }
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();