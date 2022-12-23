import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import {AdvanceMarketplaceService} from "./advanceMarketplaceService";
import dayjs = require("dayjs");
import {ERC20} from "../../ERC20";
import {GenerativeNFT} from "../../nfts/generativenft/GenerativeNFT";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const marketplaceService = new AdvanceMarketplaceService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)

        // cancel listing
        const tx = await marketplaceService.cancelListing(args[0], args[1], 0);
        console.log("tx:", tx?.transactionHash, tx?.status);

        // disapprove erc721
        let a: any = {};
        a.listingTokens = await marketplaceService.listingTokens(args[0], args[1]);
        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const disapprove = await nft.setApproveForAll(a.listingTokens._collectionContract, args[0], false, 0);
        console.log("disapprove:", disapprove?.transactionHash, disapprove?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();