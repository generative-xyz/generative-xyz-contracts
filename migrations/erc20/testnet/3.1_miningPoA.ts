import {GENTokenTestnet} from "./gentokentestnet";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contractPro = args[0];
        const genProjectAddr = args[1];
        const genProjectId = args[2];
        const erc20 = new GENTokenTestnet(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await erc20.miningPoA(contractPro, genProjectAddr, genProjectId, 0);
        console.log("Proof of Art minning GENToken ", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();