import * as dotenv from 'dotenv';
import {AdvanceMarketplaceService} from "./advanceMarketplaceService";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const marketplaceService = new AdvanceMarketplaceService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        console.log(args);

        let tx;
        // eth or erc-20
        tx = await marketplaceService.withdraw(args[0], args[1], args[2], 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();