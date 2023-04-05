import * as dotenv from 'dotenv';
import {Artifacts} from "./artifacts";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const nft = new Artifacts(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable(
            "Artifacts",
            "Artifacts",
            "0xfBA205366B7221A447FAd4D63AE04Ab6fD45d0bd"
        );
        console.log("%s GenerativeProject address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();