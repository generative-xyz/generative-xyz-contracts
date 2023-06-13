import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeProject} from "../generativeProject/generativeProject";
import {Soul} from "./soul";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const to = args[1];
        

        const nft = new Soul(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await nft.mint(contract, to, '0x0000000000000000000000000000000000000000', 0, Buffer.from(""), 0);
        console.log("tx: ", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();