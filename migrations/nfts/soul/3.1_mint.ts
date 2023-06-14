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
        // const tx = await nft.mint(contract, to, 0, '0xe34eadc4f4600d9465163d6839d245805f3ea01bc11b41f87725b37ac981f4b333d34eb07c84b2d61b792484adf562252b0bb0075786fb212e01f12df66053aa1c', 0);
        const tx = await nft.mint(contract, to, 0, '0x617c2be981bac8a372c5abe0ddaf82f431bb08083a7f142e0677d743f66e9cc40957f58774a97b0c3cdabedd6076ec95689d034baa06608c07059b9c49973d311b', 0);
        console.log("tx: ", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();