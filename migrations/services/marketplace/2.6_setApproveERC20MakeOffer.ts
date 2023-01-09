import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import {AdvanceMarketplaceService} from "./advanceMarketplaceService";
import dayjs = require("dayjs");

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const marketplaceService = new AdvanceMarketplaceService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        console.log(args);

        // support WETH
        // goerli https://goerli.etherscan.io/token/0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6
        // mumbai https://mumbai.polygonscan.com/token/0xa6fa4fb5f76172d178d61b04b0ecd319c5d1c0aa
        // mainnet https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
        const tx = await marketplaceService.setApproveERC20MakeOffer(args[0], args[1], true, 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();