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
            "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
        );
        console.log("%s GenerativeProjectData address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();