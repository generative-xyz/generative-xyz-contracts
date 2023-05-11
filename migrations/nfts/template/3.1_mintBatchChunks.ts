import * as fs from "fs";
import {ERC721Template} from "./ERC721Template";

function getByteArray(filePath: string) {
    return fs.readFileSync(filePath);
}

function readDir(dirPath: string) {
    return fs.readdirSync(dirPath);
}

(async () => {
    try {
        if (process.env.NETWORK != "tc_mainnet") {
            console.log("wrong network");
            return;
        }

        const nft = new ERC721Template(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)

        let datas = [];

        const listFiles = readDir(args[1]);
        for (let i = 0; i < listFiles.length; i++) {
            const data = getByteArray(args[1] + "/" + listFiles[i]);
            console.log("raw", data);
            datas.push([data]);
        }
        console.log(datas.length);
        const contract = args[0];
        const tx = await nft.mintBatchChunks(
                contract,
                process.env.PUBLIC_KEY,
                datas,
                0
            )
        ;
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();