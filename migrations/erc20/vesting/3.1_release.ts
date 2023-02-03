import {Gentokenvesting} from "./gentokenvesting";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const erc20 = args[1];
        let account = args[2];
        const vesting = new Gentokenvesting(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await vesting.release(contract, erc20, account, 0);
        console.log("Proof of Art minning GENToken ", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();