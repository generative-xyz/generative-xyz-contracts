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

        // cancel offer
        const tx = await marketplaceService.cancelMakeOffer(marketplaceContract, offerId, 0);
        console.log("tx:", tx?.transactionHash, tx?.status);

        // disapprove erc20
        let a: any = {};
        a.makeOfferTokens = await marketplaceService.makeOfferTokens(marketplaceContract, offerId);
        const erc20 = new ERC20(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        await erc20.decreaseAllowance(a.makeOfferTokens._erc20Token, marketplaceContract, a.makeOfferTokens._price, 0);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();