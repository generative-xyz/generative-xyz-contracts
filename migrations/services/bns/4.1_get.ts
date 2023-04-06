import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import Web3 from "web3";
import {createAlchemyWeb3} from "@alch/alchemy-web3";
import {Bns} from "./bfs";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const data = new Bns(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)

        const namesLen = await data.namesLen(args[0])
        console.log({namesLen});
        if (namesLen > 0) {
            const names = await data.getAllNames(args[0])
            console.log({names});
        }

        /*const registered = await data.registered(args[0], Buffer.from(args[1], "utf-8"));
        if (registered) {
            const tokenId = await data.registry(args[0], Buffer.from(args[1], "utf-8"));
            const resolver = await data.resolver(args[0], tokenId);
            console.log({tokenId}, {resolver});
        } else {
            return registered
        }*/
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();