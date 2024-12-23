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
    const script = (await fs.readFile('./migrations/data/cryptoai/assets/agents-thumb-300.svg')).toString();
    console.log("script", script);
    await dataContract.changePlaceHolderImg(config.dataContractAddress, 0, script);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});