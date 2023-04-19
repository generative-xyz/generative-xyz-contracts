import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {createAlchemyWeb3} from "@alch/alchemy-web3";
import dayjs = require("dayjs");
import {TrustlessPhotos} from "./photos";

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

        const nft = new TrustlessPhotos(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)

        let result = getByteArray(args[1]);
        console.log("raw", result);
        result = nft.aesEnc(result, "abc123");
        console.log("en", result);
        // result = nft.aesDec(result, "abc123");
        // console.log("de", result);
        const contract = args[0];
        const tx = await nft.upload(
                contract,
                [[result]],
                "album1",
                0
            )
        ;
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();