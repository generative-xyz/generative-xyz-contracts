import {ERC20Template} from "./ERC20Template";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const token = new ERC20Template(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        a.totalSupply = await token.totalSupply(contract);
        a.balanceOf = await token.balanceOf(contract, args[1]);
        a.name = await token.name(contract);
        console.log({a});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();