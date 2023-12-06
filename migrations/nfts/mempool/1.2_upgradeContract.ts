import {Mempool} from "./mempool";

(async () => {
    try {
        if (process.env.NETWORK != "polygon") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const nft = new Mempool(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await nft.upgradeContract(args[0]);
        console.log({address});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();