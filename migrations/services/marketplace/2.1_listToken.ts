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

        const contractMarketplace = args[0];
        const collection = args[1];
        const collectionTokenId = args[2];
        const erc20Addr = args[3];//"0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa";// mumbai WETH
        const price = ethers.utils.parseEther(args[4]);

        // approve erc-721
        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const approve = await nft.setApprovalForAll(collection, contractMarketplace, true, 0);
        console.log("approve:", approve?.transactionHash, approve?.status);

        // listing
        const tx = await marketplaceService.listToken(contractMarketplace,
            JSON.parse(JSON.stringify({
                "_collectionContract": collection,
                "_tokenId": collectionTokenId,
                "_seller": process.env.PUBLIC_KEY,
                "_price": price,
                "_erc20Token": erc20Addr,
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