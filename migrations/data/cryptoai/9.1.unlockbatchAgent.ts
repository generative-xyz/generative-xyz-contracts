import {initConfig} from "./index";
import {CryptoAIData} from "./cryptoAIData";

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
    for (let i = 1; i <= parseInt(args[0]); i++) {
        try {
            await dataContract.unlockRenderAgent(config.dataContractAddress, "30000000", i);
            console.log(i, "processed");
        } catch (e) {
            console.log(i, "failed");
            break;
        }
    }
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});