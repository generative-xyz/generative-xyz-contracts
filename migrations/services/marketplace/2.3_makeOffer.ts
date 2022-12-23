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
        const erc20Addr = args[3];//"0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa";// mumbai WETH
        const price = ethers.utils.parseEther(args[4]);

        // approve erc20
        const erc20 = new ERC20(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        await erc20.approve(erc20Addr, args[0], price, 0);

        // make offer
        const tx = await marketplaceService.makeOffer(args[0],
            JSON.parse(JSON.stringify({
                "_collectionContract": args[1],
                "_tokenId": args[2],
                "_buyer": process.env.PUBLIC_KEY,
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