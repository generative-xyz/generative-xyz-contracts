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
        let count = await data.count(args[0], process.env.PUBLIC_KEY, args[1]);
        count = parseInt(count);
        console.log(count + 1);
        let buffers = Buffer.from("");
        for (let i = 0; i <= count; i++) {
            const dataFile = await data.load(args[0], process.env.PUBLIC_KEY, args[1], i);
            const hex = dataFile[0];
            const buff = ethers.utils.arrayify(hex);
            buffers = Buffer.concat([buffers, buff]);
        }
        const dataInfo = buffers.toString("utf-8");
        console.log(dataInfo);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();