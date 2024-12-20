import {CryptoAI} from "./cryptoAI";
import {initConfig} from "../../data/cryptoai";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();

    const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    await dataContract.upgradeContract(config.contractAddress)

    // const deployer = await dataContract.getDeployer(address)
    // console.log("deployer", deployer);
    //
    // await dataContract.addItem(address, 0)
    // const item = await dataContract.getItem(address, 0)
    // console.log("item", item)
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});