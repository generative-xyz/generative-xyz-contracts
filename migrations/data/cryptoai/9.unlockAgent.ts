import {initConfig} from "./index";
import {CryptoAIData} from "./cryptoAIData";
import {promises as fs} from "fs";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();

    const args = process.argv.slice(2);
    if (args.length == 0) {
        console.log("missing number")
        return;
    }

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    await dataContract.unlockRenderAgent(config.dataContractAddress, 0, args[0]);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});