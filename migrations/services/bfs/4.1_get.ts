import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import Web3 from "web3";
import {createAlchemyWeb3} from "@alch/alchemy-web3";
import {Bfs} from "./bfs";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const data = new Bfs(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        const hash = await data.load(args[0], args[1], args[2], args[3]);
        // const hash = await data.store(args[0], 'abc', [1, 2, 3]);
        const count = await data.count(args[0], args[1], args[2]);
        console.log(hash, count);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();