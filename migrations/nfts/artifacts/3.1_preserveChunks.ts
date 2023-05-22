import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {createAlchemyWeb3} from "@alch/alchemy-web3";
import dayjs = require("dayjs");
import {Artifacts} from "./artifacts";

function getByteArray(filePath: string) {
    let fileData = fs.readFileSync(filePath);
    return fileData;
}

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }

        const nft = new Artifacts(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)

        const result = getByteArray(args[1]);

        const contract = args[0];
        const tx = await nft.preserveChunks(
                contract,
                process.env.PUBLIC_KEY,
                [result],
                0
            )
        ;
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();