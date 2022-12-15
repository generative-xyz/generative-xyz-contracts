import * as dotenv from 'dotenv';

import {ParamControl} from "./paramControl";
import {ethers} from "ethers";

(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2)
        const contract = args[0];
        const p = new ParamControl(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);

        let key = 'GENERATIVE_NFT_TEMPLATE';
        let tx = await p.setAddress(contract, key, '0xc3e53F4d16Ae77Db1c982e75a937B9f60FE63690', 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = 'CREATE_PROJECT_FEE';
        tx = await p.setUInt256(contract, key, ethers.utils.parseEther("0.001"), 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "BASE_URI";
        tx = await p.set(contract, key, "http://devnet.generative.xyz/api/token", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "BASE_URI_TRAIT";
        tx = await p.set(contract, key, "http://devnet.generative.xyz/api/trait", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = 'FEE_TOKEN';
        tx = await p.setAddress(contract, key, "0x0000000000000000000000000000000000000000", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "MINT_NFT_OPERATOR_FEE";
        tx = await p.setUInt256(contract, key, 500, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "p5js@1.5.0"
        tx = await p.set(contract, key, `<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.5.0/p5.min.js"></script>`, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "threejs@r124"
        tx = await p.set(contract, key, `<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r124/three.min.js"></script>`, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "tonejs@14.8.49"
        tx = await p.set(contract, key, `<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/tone/14.8.49/Tone.js"></script>`, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();