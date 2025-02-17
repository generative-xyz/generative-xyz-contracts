import {initConfig} from "./index";
import {CryptoAIData} from "./cryptoAIData";

async function main() {
    if (process.env.NETWORK != "base_mainnet") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    await dataContract.unsealContract(config.dataContractAddress, 0);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});