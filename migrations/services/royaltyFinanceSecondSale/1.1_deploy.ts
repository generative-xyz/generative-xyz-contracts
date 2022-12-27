import * as dotenv from 'dotenv';
import {RoyaltyFinanceSecondSale} from "./royaltyFinanceSecondSale";


(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const nft = new RoyaltyFinanceSecondSale(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.deployUpgradeable(
            process.env.PUBLIC_KEY,
            "0x47B528E9eDD8f7Dd709bCa9f7E45c499C85eccfb",
            "0x12E258A3307DeDDb26478D274a3C9343cf9107D6",
            process.env.PUBLIC_KEY);
        console.log("%s RoyaltyFinanceSecondSale address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();