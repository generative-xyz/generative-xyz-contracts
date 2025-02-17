import {CryptoAI} from "./cryptoAI";
import {initConfig} from "../../data/cryptoai";

async function main() {
    if (process.env.NETWORK != "base_mainnet") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();

    const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    await dataContract.allowAdmin(config.contractAddress, 0, "0x8eaf68B6A6AD411B260699B0aC24Ad839F72FC07", true);

}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});