import {GENToken} from "./gentoken";

(async () => {
    try {
        if (process.env.NETWORK != "goerli") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contractPro = args[0];
        const genProjectAddr = args[1];
        let genProjectId = args[2];
        const erc20 = new GENToken(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        // for (let i = 7; i <= 14; i++) {
        // genProjectId = i;
        const tx = await erc20.miningPoA(contractPro, genProjectAddr, genProjectId, 0);
        console.log("Proof of Art minning GENToken ", tx?.transactionHash, tx?.status);
        // }
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();