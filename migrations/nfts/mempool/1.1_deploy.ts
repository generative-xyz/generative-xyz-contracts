import * as dotenv from 'dotenv';
import {Mempool} from "./mempool";


(async () => {
    try {
        if (process.env.NETWORK != "polygon") {
            console.log("wrong network");
            return;
        }
        const nft = new Mempool(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable("Mempool", "Mempool",
            process.env.PUBLIC_KEY)
        console.log("%s Mempool address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();