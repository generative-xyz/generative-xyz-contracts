import {AdvanceMarketplaceService} from "./advanceMarketplaceService";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const marketplace = new AdvanceMarketplaceService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await marketplace.upgradeContract(args[0]);
        console.log({address});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();