import * as dotenv from 'dotenv';
import {SoulGMVotingToken} from "./SoulGMVotingToken";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const erc20 = new SoulGMVotingToken(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await erc20.deployUpgradeable("SOULGMVOTING", "SOULGMVOTING",
            process.env.PUBLIC_KEY,
            "0xdD7aD504f81B00C53c2F2c37c9b8185EA8c4D8A0",
            "0x9Aaf0539d2261bB0788Ed22CEE50C8a0219E99e4");
        console.log("%s SoulGMVotingToken address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();