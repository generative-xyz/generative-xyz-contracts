import * as dotenv from 'dotenv';
import {GENTokenTestnet} from "./gentokentestnet";


(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const erc20 = new GENTokenTestnet(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await erc20.deployUpgradeable(
            "GENToken",
            "GENToken",
            process.env.PUBLIC_KEY,
            "0x47B528E9eDD8f7Dd709bCa9f7E45c499C85eccfb",
        );
        console.log("%s GENToken address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();