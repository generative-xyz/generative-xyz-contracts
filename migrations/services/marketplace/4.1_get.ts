import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {AdvanceMarketplaceService} from "./advanceMarketplaceService";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const marketplaceService = new AdvanceMarketplaceService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        // a.listingTokens = await marketplaceService.listingTokens(contract, args[1]);
        // a.makeOfferTokens = await marketplaceService.makeOfferTokens(contract, args[1]);
        a._arrayListingId = await marketplaceService._arrayListingId(contract, args[1]);
        console.log({a});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();