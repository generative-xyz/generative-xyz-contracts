import * as dotenv from 'dotenv';
import {Soul} from "./soul";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const nft = new Soul(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable("Soul", "Soul",
            process.env.PUBLIC_KEY,
            "0xdD7aD504f81B00C53c2F2c37c9b8185EA8c4D8A0",
            "0x039489F7465DdCfd54bE18907790873269Dc7c55",
            "0x9Aaf0539d2261bB0788Ed22CEE50C8a0219E99e4",
            "0xF75Cc7C8ff32Fe64a3AF00Ad45B8eca3A690a605",
            "0x13BB7Bf390B55A7d5bF44c4dcEcdFEB1Dd2a884a");
        console.log("%s Soul address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();