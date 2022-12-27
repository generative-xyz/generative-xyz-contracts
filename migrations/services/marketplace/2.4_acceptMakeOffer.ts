import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import {AdvanceMarketplaceService} from "./advanceMarketplaceService";
import dayjs = require("dayjs");
import {GenerativeNFT} from "../../nfts/generativenft/GenerativeNFT";
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
        a.makeOfferTokens = await marketplaceService.makeOfferTokens(marketplaceContract, offerId);

        // const erc20 = new ERC20(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        // const allowance = await erc20.allowance(a.makeOfferTokens._erc20Token, a.makeOfferTokens._buyer, marketplaceContract);
        // console.log("allowance", allowance);

        console.log("approve erc-721");
        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const approve = await nft.setApprovalForAll(a.makeOfferTokens._collectionContract, marketplaceContract, true, 0);
        console.log("approve:", approve?.transactionHash, approve?.status);

        // accept offer
        const tx = await marketplaceService.acceptMakeOffer(marketplaceContract, offerId, 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();