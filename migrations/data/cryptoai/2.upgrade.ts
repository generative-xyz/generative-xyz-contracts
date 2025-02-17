import {CryptoAIData} from "./cryptoAIData";
import {initConfig} from "./index";

async function main() {
    if (process.env.NETWORK != "base_mainnet") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    await dataContract.upgradeContract(config.dataContractAddress)

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