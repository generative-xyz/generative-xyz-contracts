import * as dotenv from 'dotenv';

import {BigNumber, ethers} from "ethers";
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
        const offerIds = JSON.parse(args[1]);

        let offers: any = [];
        let prices: BigNumber = ethers.utils.parseUnits("0");
        let listingTokens;
        for (let i = 0; i < offerIds.length; i++) {
            listingTokens = await marketplaceService.listingTokens(marketplaceContract, offerIds[i]);
            prices = prices.add(ethers.utils.parseUnits(listingTokens._price, 0));
            offers.push(offerIds[i]);
        }

        // approve erc20
        if (listingTokens._erc20Token != "0x0000000000000000000000000000000000000000") {
            const erc20 = new ERC20(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
            erc20.approve(listingTokens._erc20Token, marketplaceContract, prices, 0);
        }

        console.log(offers);
        console.log(prices.toString());
        // sweep tokens
        const tx = await marketplaceService.sweep(marketplaceContract, offers, prices, 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();