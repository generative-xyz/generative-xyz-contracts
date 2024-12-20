import {initConfig} from "./index";
import {CryptoAIData} from "./cryptoAIData";

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
    const num = parseInt(args[0]);
    for (var i = 1; i <= num; i++) {
        try {
            await dataContract.cryptoAIImage(address, i);
            console.log(i, " processed");
        } catch (ex) {
            console.log(i, " failed");
            break;
        }
    }
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});

