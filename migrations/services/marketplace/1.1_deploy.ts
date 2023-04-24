import * as dotenv from 'dotenv';
import {AdvanceMarketplaceService} from "./advanceMarketplaceService";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const marketplace = new AdvanceMarketplaceService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await marketplace.deployUpgradeable(process.env.PUBLIC_KEY, "0x984eEd0C15353bA88d8f35FD929e260bf70d03BD");
        console.log("%s AdvanceMarketplaceService address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();