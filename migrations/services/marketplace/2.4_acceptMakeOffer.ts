import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import {AdvanceMarketplaceService} from "./advanceMarketplaceService";
import dayjs = require("dayjs");
import {GenerativeNFT} from "../../nfts/generativenft/GenerativeNFT";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const marketplaceService = new AdvanceMarketplaceService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        let a: any = {};
        a.makeOfferTokens = await marketplaceService.makeOfferTokens(args[0], args[1]);

        // approve erc-721
        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const approve = await nft.setApproveForAll(a._collectionContract, args[0], true, 0);
        console.log("approve:", approve?.transactionHash, approve?.status);

        // accept offer
        const tx = await marketplaceService.acceptMakeOffer(args[0], args[1], 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();