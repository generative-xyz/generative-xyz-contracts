import {initConfig} from "./index";
import {CryptoAIData} from "./cryptoAIData";
import {promises as fs} from "fs";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();
    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    //ADD Element
    const address = config["dataContractAddress"];

    // Render SVG
    const args = process.argv.slice(2);
    if (args.length == 0) {
        console.log("missing number")
        return;
    }
    const data = await dataContract.tokenURI(address, parseInt(args[0]));
    const path = "./migrations/data/cryptoai/token_" + args[0] + ".json";
    console.log("path", path);
    await fs.writeFile(path, data);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});

