import * as dotenv from 'dotenv';
import {GENToken} from "./gentoken";


(async () => {
    try {
        if (process.env.NETWORK != "tc_mainnet") {
            console.log("wrong network");
            return;
        }
        const erc20 = new GENToken(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await erc20.deployUpgradeable(
            "GEN",
            "GEN",
            process.env.PUBLIC_KEY,
            "0x984eEd0C15353bA88d8f35FD929e260bf70d03BD",
        );
        console.log("%s GENToken address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();