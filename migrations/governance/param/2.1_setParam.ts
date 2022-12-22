import * as dotenv from 'dotenv';

import {ParamControl} from "./paramControl";
import {ethers} from "ethers";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2)
        const contract = args[0];
        const key = 'GENERATIVE_NFT_TEMPLATE';
        const nft = new ParamControl(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);

        const val: any = await nft.getAddress(contract, key);
        console.log("val", val);

        let tx = await nft.setAddress(contract, key, '0xcE9abD6c468ac4d9006cEE7aE51D2c6bC66f2eD6', 0);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);


    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();