import {CryptoAI} from "./cryptoAI";
import {initConfig} from "../../data/cryptoai";

async function main() {
    // if (process.env.NETWORK != "base_mainnet") {
    //     console.log("wrong network");
    //     return;
    // }

    let config = await initConfig();

    const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);

    const pointers = [
        {
            retrieveAddress: "0x0000000000000000000000000000000000000000", // Using IPFS (zero address)
            fileType: 0, // LIBRARY type
            fileName: "QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco" // Example IPFS hash
        },
        {
            retrieveAddress: "0x0000000000000000000000000000000000000000",
            fileType: 1, // MAIN_SCRIPT type
            fileName: "QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ"
        }
    ];
    const depsAgents = [
        2, 
        3 
    ];

    const codeLanguage = "Python"; // Using Python as the code language
    const aiAgentId = 2;

    await dataContract.publishAgentCode(config.contractAddress, 0, aiAgentId, codeLanguage, pointers, depsAgents);

}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});