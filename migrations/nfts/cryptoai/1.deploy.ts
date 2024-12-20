import {CryptoAI} from "./cryptoAI";
import {initConfig, updateConfig} from "../../data/cryptoai";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }
    const config = await initConfig();
    const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    const address = await dataContract.deployUpgradeable("test", "test",
        process.env.PUBLIC_KEY,
        process.env.PUBLIC_KEY)
    console.log('CryptoAIData contract address:', address);
    await updateConfig("contractAddress", address);
    console.log('Deploy succesful');
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});