import * as dotenv from 'dotenv';
import {ERC721Template} from "./ERC721Template";
import * as fs from "fs";

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
        const args = process.argv.slice(2)
        const data = getByteArray(args[0]);
        const erc20 = new ERC721Template(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await erc20.deploy(
            "abc", [[data]]
        );
        console.log("%s ERC721Template address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();