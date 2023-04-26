import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {Wtc} from "./wtc";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const token = new Wtc(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        a.totalSupply = await token.totalSupply(contract);
        a.balanceOf = await token.balanceOf(contract, process.env.PUBLIC_KEY);
        a.name = await token.name(contract);
        a.symbol = await token.symbol(contract);
        console.log({a});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();