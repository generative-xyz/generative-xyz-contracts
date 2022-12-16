import * as dotenv from 'dotenv';
import {GenerativeProjectData} from "./generativeProjectData";


(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const nft = new GenerativeProjectData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable(
            process.env.PUBLIC_KEY,
            "0x5FbDB2315678afecb367f032d93F642f64180aa3",
            "0xCace1b78160AE76398F486c8a18044da0d66d86D",
        );
        console.log("%s GenerativeProjectData address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();