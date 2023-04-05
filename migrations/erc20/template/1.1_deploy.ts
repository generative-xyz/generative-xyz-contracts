import * as dotenv from 'dotenv';
import {ERC20Template} from "./ERC20Template";


(async () => {
    try {
        if (process.env.NETWORK != "tc_mainnet") {
            console.log("wrong network");
            return;
        }
        const erc20 = new ERC20Template(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await erc20.deploy(
            "abc",
            "abc",
        );
        console.log("%s GENToken address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();