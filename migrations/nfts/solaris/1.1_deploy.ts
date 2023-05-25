import * as dotenv from 'dotenv';
import {Solaris} from "./Solaris";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const nft = new Solaris(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable("Solaris", "SOL",
            process.env.PUBLIC_KEY,
            "0xdc913D967D6bD734Cc435cDf139E60a6828030EC",
            "0xaA320251332e77620317080C9464df9F33291E81",
            "0xACd7aeAe6B4e8B7EF7fc87f0d0F0824DBa9f9927");
        console.log("%s GenerativeNFT address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();