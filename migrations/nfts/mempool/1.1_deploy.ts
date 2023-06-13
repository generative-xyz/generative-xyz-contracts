import * as dotenv from 'dotenv';
import {Mempool} from "./mempool";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const nft = new Mempool(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable("Mempool", "Mempool",
            process.env.PUBLIC_KEY,
            "0xdD7aD504f81B00C53c2F2c37c9b8185EA8c4D8A0",
            "0x039489F7465DdCfd54bE18907790873269Dc7c55",
            "0xF75Cc7C8ff32Fe64a3AF00Ad45B8eca3A690a605");
        console.log("%s Solaris address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();