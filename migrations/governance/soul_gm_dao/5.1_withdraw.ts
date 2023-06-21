import * as dotenv from 'dotenv';
import {SoulGmDao} from "./soulGmDao";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const treasury = new SoulGmDao(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        console.log(args);

        let tx;
        // eth or erc-20
        tx = await treasury.withdraw(args[0], args[1], args[2], 0);
        console.log("tx:", tx?.transactionHash, tx?.status);

        // erc-721
        /*tx = await treasury.withdrawERC721(args[0], args[1], args[2], 0);
        console.log("tx:", tx?.transactionHash, tx?.status);*/

        // erc-1155
        /*tx = await treasury.withdrawERC1155(args[0], args[1], args[2], args[3], 0);
        console.log("tx:", tx?.transactionHash, tx?.status);*/

    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();