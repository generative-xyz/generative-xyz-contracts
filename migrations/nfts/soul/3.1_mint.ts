import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeProject} from "../generativeProject/generativeProject";
import {Soul} from "./soul";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const to = args[1];
        

        const nft = new Soul(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await nft.mint(contract, to, '0xF61234046A18b07Bf1486823369B22eFd2C4507F', 0, '0xff8dc63509256679db9fcd5c3b569484705eaebf1ca681a21e6f9152441f6324345c6c8c36cd678ad34a13746579e63dbcc365bcbc65ef49c4e35276805f62131c', 0);
        console.log("tx: ", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();