import * as dotenv from 'dotenv';
import {Treasury} from "./treasury";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const treasury = new Treasury(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await treasury.deployUpgradeable(
            process.env.PUBLIC_KEY,
            "0xdD7aD504f81B00C53c2F2c37c9b8185EA8c4D8A0",
            process.env.PUBLIC_KEY
        );
        console.log("%s GM Dao Treasury address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();