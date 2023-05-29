import * as fs from "fs";
import {Bfs} from "./bfs";


function sleep(ms: number) {
    return new Promise((resolve) => {
        setTimeout(resolve, ms);
    });
}

function getByteArray(filePath: string) {
    return fs.readFileSync(filePath);
}

(async () => {
    try {
        if (process.env.NETWORK !== "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const data = new Bfs(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        const file = args[1]
        const fileName = file.split("/")[file.split("/").length - 1];
        const rawdata = getByteArray(file);
        // partition rawdata into chunks
        const chunksize = 350_000;
        let chunks = [];
        for (let i = 0; i < rawdata.length; i += chunksize) {
            const temp = rawdata.slice(i, i + chunksize)
            chunks.push(temp);
            console.log("chunk - ", temp)
        }
        console.log("Split to ", chunks.length);
        for (let i = 2; i < chunks.length; i++) {
            try {
                console.log('inscribe chunk', i, 'of file', fileName, 'with', chunks[i].length, 'bytes');
                const tx = await data.store(args[0], fileName, i, chunks[i], 250000000);
                console.log("tx:", tx?.transactionHash, tx?.status);
                await sleep(3000);
                break;
            } catch (e) {
                console.log("Error: ", e);
            }
        }

    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();