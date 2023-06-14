import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {Mempool} from "./mempool";

(async () => {
    try {
        if (process.env.NETWORK != "tc_mainnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const to = args[1];


        const nft = new Mempool(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let nonce = 1102;
        for (let i = 0; i < 69; i++) {
            nft.mint(contract, to, 300000, nonce);
            nonce++;
            // console.log("tx: ", tx?.transactionHash, tx?.status);
        }
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();