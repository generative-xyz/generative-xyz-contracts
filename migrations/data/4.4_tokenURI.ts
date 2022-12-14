import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import {GalaxyData} from "./galaxydata";
import Web3 from "web3";
import {createAlchemyWeb3} from "@alch/alchemy-web3";

const hardhatConfig = require("../../../hardhat.config");

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const data = new GalaxyData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        const html = await data.tokenURI(args[0], args[1]);
        console.log(html);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();