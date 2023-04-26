import {Wtc} from "./wtc";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contractPro = args[0];
        const erc20 = new Wtc(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await erc20.deposit(contractPro, args[1], 0);
        console.log("Deposit WTC ", tx?.transactionHash, tx?.status);
        // }
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();