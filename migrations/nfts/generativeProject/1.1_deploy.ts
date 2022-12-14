import * as dotenv from 'dotenv';
import {GenerativeProject} from "./generativeProject";


(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const nft = new GenerativeProject(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable(
            "generative.xyz",
            "genXYZ",
            process.env.PUBLIC_KEY,
            "0x46C02B9113DcA70a8C2e878Df0B24Dc895836b75",
            "0x85558d2C958684C6cB1f65e2E94cDb8945DF9E7f",
            "0x0000000000000000000000000000000000000000"
        );
        console.log("%s GenerativeProject address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();