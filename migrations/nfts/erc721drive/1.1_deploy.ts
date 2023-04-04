import * as dotenv from 'dotenv';
import {Erc721Drive} from "./erc721Drive";


(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const nft = new Erc721Drive(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable(
            "TC-file",
            "TC-file",
            "0xF75Cc7C8ff32Fe64a3AF00Ad45B8eca3A690a605"
        );
        console.log("%s GenerativeProject address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();