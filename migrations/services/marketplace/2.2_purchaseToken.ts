import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import {AdvanceMarketplaceService} from "./advanceMarketplaceService";
import dayjs = require("dayjs");
import {ERC20} from "../../ERC20";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const marketplaceService = new AdvanceMarketplaceService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)

        const marketplaceContract = args[0];
        const offerId = args[1];

        let a: any = {};
        a.listingTokens = await marketplaceService.listingTokens(marketplaceContract, offerId);

        // approve erc20
        if (a.listingTokens._erc20Token != "0x0000000000000000000000000000000000000000") {
            const erc20 = new ERC20(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
            erc20.approve(a.listingTokens._erc20Token, marketplaceContract, a.listingTokens._price, 0);
        }

        // purchase token
        const tx = await marketplaceService.purchaseToken(marketplaceContract, offerId, a.listingTokens._price, 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();