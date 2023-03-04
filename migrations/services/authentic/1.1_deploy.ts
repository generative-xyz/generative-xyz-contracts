import * as dotenv from 'dotenv';
import {AuthenticService} from "./AuthenticService";


(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const service = new AuthenticService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await service.deployUpgradeable(process.env.PUBLIC_KEY, "0x0000000000000000000000000000000000000000");
        console.log("%s AuthenticService address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();