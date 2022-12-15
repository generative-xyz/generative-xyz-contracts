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
        let tx = await p.setAddress(contract, key, '0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e', 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = 'CREATE_PROJECT_FEE';
        tx = await p.setUInt256(contract, key, ethers.utils.parseEther("0.001"), 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);


        key = 'FEE_TOKEN';
        tx = await p.setAddress(contract, key, "0x0000000000000000000000000000000000000000", 0);
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