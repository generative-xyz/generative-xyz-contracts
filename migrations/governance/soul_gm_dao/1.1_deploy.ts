import * as dotenv from 'dotenv';
import {SoulGmDao} from "./soulGmDao";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const genDAO = new SoulGmDao(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await genDAO.deployUpgradeable(
            "SoulGmDao",
            process.env.PUBLIC_KEY,
            "0xdD7aD504f81B00C53c2F2c37c9b8185EA8c4D8A0",
            "0xabcc390352873B56f5342B0198ef27317D7a5721",
            "0x85802F1f36F549334EeeEf6715Ed16555ed7178b",
            "0x9Aaf0539d2261bB0788Ed22CEE50C8a0219E99e4"
        );
        console.log("%s SoulGmDao address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();