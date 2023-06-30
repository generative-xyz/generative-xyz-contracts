import * as dotenv from 'dotenv';
import {GenerativeNFTUpgradeable} from "./GenerativeNFT";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const nft = new GenerativeNFTUpgradeable(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deploy();
        console.log("%s GenerativeNFTUpgradeable address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();