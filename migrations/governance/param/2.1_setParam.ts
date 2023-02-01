import * as dotenv from 'dotenv';

import {ParamControl} from "./paramControl";
import {ethers} from "ethers";

(async () => {
    try {
        if (process.env.NETWORK != "goerli") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2)
        const contract = args[0];
        const key = 'MINT_NFT_OPERATOR_FEE';
        const nft = new ParamControl(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);

        const val: any = await nft.getUInt256(contract, key);
        console.log("val", val);

        let tx = await nft.setUInt256(contract, key, 500, 100000);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);


    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();