import {ERC20} from "../ERC20";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contractPro = args[0];
        const spender = args[1];
        let amount = args[2];
        const erc20 = new ERC20(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await erc20.approve(contractPro, spender, '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', 0);
        console.log("Transfer ", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();