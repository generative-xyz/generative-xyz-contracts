import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import {GenerativeProjectData} from "./generativeProjectData";

(async () => {
    try {
        if (process.env.NETWORK != "tc_mainnet") {
            console.log("wrong network");
            return;
        }
        const nft = new GenerativeProjectData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        console.log(args);
        const tx = await nft.changeBfs(args[0], args[1], 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();