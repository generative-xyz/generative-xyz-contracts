import {CryptoAI} from "./cryptoAI";
import {initConfig} from "../../data/cryptoai";

async function main() {
    if (process.env.NETWORK != "base_mainnet") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();

    const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    await dataContract.changeCryptoAiDataAddress(config.contractAddress, 0, config.dataContractAddress);

}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});