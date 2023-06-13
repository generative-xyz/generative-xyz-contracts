import * as dotenv from 'dotenv';
import {Soul} from "./soul";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const nft = new Soul(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable("Solaris", "SOL",
            process.env.PUBLIC_KEY,
            "0x979aC806367604e13A921c72b95023dA1889a6Fd",
            "0x039489F7465DdCfd54bE18907790873269Dc7c55",
            "0x9Aaf0539d2261bB0788Ed22CEE50C8a0219E99e4",
            "0xF75Cc7C8ff32Fe64a3AF00Ad45B8eca3A690a605",
            process.env.PUBLIC_KEY);
        console.log("%s Solaris address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();