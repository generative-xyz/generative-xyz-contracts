import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {RoyaltyFinanceSecondSale} from "./royaltyFinanceSecondSale";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const service = new RoyaltyFinanceSecondSale(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        // a.royaltySecondSale = await service.royaltySecondSale(contract, args[1], args[2], args[3]);
        a.royaltySecondSaleAdmin = await service.royaltySecondSaleAdmin(contract, args[1]);
        console.log({a});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();