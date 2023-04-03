import * as dotenv from 'dotenv';

import {GenerativeNFT} from "./GenerativeNFT";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deploy("Template", "Template");
        console.log("%s GenerativeNFT address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();