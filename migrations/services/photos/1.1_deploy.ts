import * as dotenv from 'dotenv';
import {TrustlessPhotos} from "./photos";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const nft = new TrustlessPhotos(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable(
            process.env.PUBLIC_KEY,
            "",
            ""
        );
        console.log("%s GenerativeProject address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();