import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import dayjs = require("dayjs");
import {RoyaltyFinanceSecondSale} from "./royaltyFinanceSecondSale";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const service = new RoyaltyFinanceSecondSale(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        console.log(args);
        const tx = await service.setProxyRoyaltySecondSale(args[0], args[1], true, 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();