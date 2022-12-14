import * as dotenv from 'dotenv';

import {ParamControl} from "./paramControl";
import {ethers} from "ethers";

(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const contract = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
        const key = 'GENERATIVE_NFT_TEMPLATE';
        const nft = new ParamControl(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);

        const val: any = await nft.getAddress(contract, key);
        console.log("val", val);

        let tx = await nft.setAddress(contract, key, '0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e', 0);
        console.log("%s tx: %s", process.env.NETWORK, tx);


    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();