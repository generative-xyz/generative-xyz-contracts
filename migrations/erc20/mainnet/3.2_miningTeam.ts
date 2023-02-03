import {GENToken} from "./gentoken";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contractPro = args[0];
        const erc20 = new GENToken(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        // for (let i = 7; i <= 14; i++) {
        // genProjectId = i;
        const tx = await erc20.miningTeam(contractPro, 0);
        console.log("Team vesting GENToken ", tx?.transactionHash, tx?.status);
        // }
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();