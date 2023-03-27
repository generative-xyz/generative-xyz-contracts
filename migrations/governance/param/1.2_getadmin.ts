import * as dotenv from 'dotenv';

import {ParamControl} from "./paramControl";

(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2)
        const nft = new ParamControl(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let admin = await nft.getAdminAddress(args[0]);
        console.log("%s ParamControl admin address: %s", process.env.NETWORK, admin);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();