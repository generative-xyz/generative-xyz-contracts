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

        // approve
        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const approve = await nft.setApproveForAll(args[1], args[0], true, 0);
        console.log("approve:", approve?.transactionHash, approve?.status);

        // listing
        const tx = await marketplaceService.listToken(args[0],
            JSON.parse(JSON.stringify({
                "_collectionContract": args[1],
                "_tokenId": args[2],
                "_seller": process.env.PUBLIC_KEY,
                "_price": ethers.utils.parseEther("0.009"),
                "_erc20Token": "0x0000000000000000000000000000000000000000",
                "_closed": false,
                "_durationTime": dayjs().add(1, "day").unix(),
            }))
            , 0);
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();