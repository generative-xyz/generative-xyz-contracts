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

        /**
         *  For project
         */
        let key = 'GENERATIVE_NFT_TEMPLATE'; // template of generative nft
        let tx = await p.setAddress(contract, key, '0x5FbDB2315678afecb367f032d93F642f64180aa3', 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = 'CREATE_PROJECT_FEE'; // operator fee get when creator create project
        tx = await p.setUInt256(contract, key, ethers.utils.parseEther("0.001"), 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = 'FEE_TOKEN'; // operator fee erc-20 get when creator create project
        tx = await p.setAddress(contract, key, "0x0000000000000000000000000000000000000000", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        /**
         * for generative nft
         */
        key = "ROYALTY_FIN_ADDRESS"; // royalty second sale address from service RoyaltyFinanceSecondSale
        tx = await p.setAddress(contract, key, "0xE5C005577149b977BB4E2B9B1a31d24c06CE80c3", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "DEFAULT_ROYALTY_FIN_PERCENT"; // default get for royalty second sale address 5%
        tx = await p.setUInt256(contract, key, 500, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "MINT_NFT_OPERATOR_FEE"; // operator fee when collector mint generative nft from project
        tx = await p.setUInt256(contract, key, 500, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "MINT_NFT_OPERATOR_TREASURE_ADDR";// hold operator fee when minting generative nft of project - default is admin
        // tx = await p.setAddress(contract, key, "", 0);
        // console.log("set ", key);
        // console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);
        /**
         * For Project Data
         */
        key = "BASE_URI";
        tx = await p.set(contract, key, "http://devnet.generative.xyz/api/token", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "BASE_URI_TRAIT";
        tx = await p.set(contract, key, "http://devnet.generative.xyz/api/trait", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "RANDOM_FUNC_SCRIPT";
        tx = await p.set(contract, key, '<script id="snippet-random-code" type="text/javascript">const urlSeed=new URLSearchParams(window.location.search).get("seed");urlSeed&&urlSeed.length>0&&(tokenData.seed=urlSeed);const tokenId=tokenData.tokenId,ONE_MIL=1e6,projectNumber=Math.floor(parseInt(tokenData.tokenId)/1e6),tokenMintNumber=parseInt(tokenData.tokenId)%1e6,seed=tokenData.seed;function cyrb128($){let _=1779033703,e=3144134277,t=1013904242,n=2773480762;for(let r=0,u;r<$.length;r++)_=e^Math.imul(_^(u=$.charCodeAt(r)),597399067),e=t^Math.imul(e^u,2869860233),t=n^Math.imul(t^u,951274213),n=_^Math.imul(n^u,2716044179);return _=Math.imul(t^_>>>18,597399067),e=Math.imul(n^e>>>22,2869860233),t=Math.imul(_^t>>>17,951274213),n=Math.imul(e^n>>>19,2716044179),[(_^e^t^n)>>>0,(e^_)>>>0,(t^_)>>>0,(n^_)>>>0]}function sfc32($,_,e,t){return function(){e>>>=0,t>>>=0;var n=($>>>=0)+(_>>>=0)|0;return $=_^_>>>9,_=e+(e<<3)|0,e=(e=e<<21|e>>>11)+(n=n+(t=t+1|0)|0)|0,(n>>>0)/4294967296}}let mathRand=sfc32(...cyrb128(seed));</script>', 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        /**
         * For royalty second sale
         */
        key = "OWNER_ROYALTY_SECOND_SALE"; // percent split from royalty second sale for owner of project
        tx = await p.setUInt256(contract, key, 9000, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        // JS lib by version
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