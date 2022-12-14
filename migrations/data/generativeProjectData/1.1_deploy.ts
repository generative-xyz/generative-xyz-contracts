import * as dotenv from 'dotenv';
import {GenerativeProjectData} from "./generativeProjectData";


(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const nft = new GenerativeProjectData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable(
            process.env.PUBLIC_KEY,
            "0x46C02B9113DcA70a8C2e878Df0B24Dc895836b75",
            "0x11D23D658eB85EA86B1dE4F1347f77fB79790Dc5",
        );
        console.log("%s GenerativeProjectData address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();