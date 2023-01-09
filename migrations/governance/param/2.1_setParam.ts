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

        let tx = await nft.setAddress(contract, key, "0x52C1394DD5a64dd42847983615b88a04a041C017", 0);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);


    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();