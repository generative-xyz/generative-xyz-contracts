import * as dotenv from 'dotenv';
import {AdvanceMarketplaceService} from "./advanceMarketplaceService";


(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const marketplace = new AdvanceMarketplaceService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await marketplace.deployUpgradeable(process.env.PUBLIC_KEY, "0x47B528E9eDD8f7Dd709bCa9f7E45c499C85eccfb");
        console.log("%s AdvanceMarketplaceService address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();