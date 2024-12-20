import {CryptoAIData} from "./cryptoAIData";
import {initConfig} from "./index";

// import {DATA_DNA, DNA} from "./data";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let configaaa = await initConfig();

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);

    //ADD Element
    const address = configaaa["dataContractAddress"];

    const ele: [] = await dataContract.getItem(address, 'Eyes')
    console.log('ele', ele)

    // const ele = await dataContract.getDNA(address)
    // console.log('ele', ele)
    // const dna = await dataContract.getDNA(address, 2);
    // console.log('dna', dna);

    //
    // for (const dna of DATA_DNA) {
    //     const getDNAVariant = await dataContract.getDNAVariant(address, 0, dna.key);
    //     console.log("getDNAVariant", getDNAVariant);
    // }

    // for (const dna of DATA_DNA) {
    //     const getDNAVariant = await dataContract.getDNAVariantTraits(address, 2, dna.key);
    //     console.log(dna.key, getDNAVariant);
    // }

}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});