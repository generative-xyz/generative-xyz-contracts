import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import Web3 from "web3";
import {createAlchemyWeb3} from "@alch/alchemy-web3";
import {RandomizerService} from "./randomizerService";

(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const data = new RandomizerService(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        const hash = await data.generateTokenHash(args[0], args[1]);
        console.log(hash);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();