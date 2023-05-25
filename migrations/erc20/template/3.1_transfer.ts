import {ERC20Template} from "./ERC20Template";

(async () => {
    try {
        if (process.env.NETWORK != "goerli") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contractPro = args[0];
        const to = args[1];
        let amount = args[2];
        const erc20 = new ERC20Template(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await erc20.transfer(contractPro, to, amount, 0);
        console.log("Transfer ", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();