import * as fs from "fs";
import {Artifacts} from "./artifacts";

function getByteArray(filePath: string) {
    return fs.readFileSync(filePath);
}

(async () => {
    try {
        if (process.env.NETWORK != "tc_mainnet") {
            console.log("wrong network");
            return;
        }

        const nft = new Artifacts(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)

        const contract = args[0];
        const tokenId = args[1];

        const rawdata = getByteArray(args[2]);

        // partition rawdata into chunks
        // const chunksize = 350_000;
        const chunksize = 1_000;
        let chunks = [];
        for (let i = 0; i < rawdata.length; i += chunksize) {
            const temp = rawdata.slice(i, i + chunksize);
            chunks.push(temp);
            console.log("chunk - ", temp)
        }
        console.log("Split to ", chunks.length);
        let nonce = 558
        for (let i = 0; i < chunks.length; i++) {
            try {
                console.log('inscribe chunk', i, 'with', chunks[i].length, 'bytes');
                nft.store(contract, tokenId, i, chunks[i], 0, nonce);
                nonce++;
            } catch (e) {
                console.log("Error: ", e);
            }
        }
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();