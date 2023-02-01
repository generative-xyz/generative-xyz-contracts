import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GENToken} from "./gentoken";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const token = new GENToken(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        a.totalSupply = await token.totalSupply(contract);
        a.proofOfArtAvailable = await token.proofOfArtAvailable(contract, args[1], args[2]);
        console.log({a});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();