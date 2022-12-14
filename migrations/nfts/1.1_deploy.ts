import * as dotenv from 'dotenv';
import {GenerativeProject} from "./generativeProject";


(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const nft = new GenerativeProject(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable(
            "generative.xyz",
            "genXYZ",
            process.env.PUBLIC_KEY,
            "0x46C02B9113DcA70a8C2e878Df0B24Dc895836b75",
        );
        console.log("%s GenerativeProject address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();