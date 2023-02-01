import * as dotenv from 'dotenv';
import {Treasury} from "./treasury";


(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const treasury = new Treasury(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await treasury.deployUpgradeable(
            process.env.PUBLIC_KEY,
            "0x47B528E9eDD8f7Dd709bCa9f7E45c499C85eccfb",
            "0x375F4B6a1F7216930b14eE57245c71A0a1CD8C34"
        );
        console.log("%s GENT Dao Treasury address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();