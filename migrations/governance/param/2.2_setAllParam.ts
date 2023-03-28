import * as dotenv from 'dotenv';

import {ParamControl} from "./paramControl";
import {ethers} from "ethers";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2)
        const contract = args[0];
        const p = new ParamControl(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);

        /**
         *  For project
         */
        let key = "";
        let tx = null;

        key = 'GENERATIVE_NFT_TEMPLATE'; // template of generative nft
        tx = await p.setAddress(contract, key, '0x23Df0DB38fc6AdD998977B717B3d8fEb95040630', 0);
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
        tx = await p.setAddress(contract, key, "0xDb4D890eC554B380A95f35f07d275893fCfe328f", 0);
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
        tx = await p.setAddress(contract, key, "0x833667aa22F6048993dD9047CdE98beB88C2876E", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "BFS_ADDRESS"
        tx = await p.setAddress(contract, key, "0xf75cc7c8ff32fe64a3af00ad45b8eca3a690a605", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);
        /**
         * For Project Data
         */
        key = "BASE_URI";
        tx = await p.set(contract, key, "http://testnet.generative.xyz/generative/api/token", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "BASE_URI_TRAIT";
        tx = await p.set(contract, key, "http://testnet.generative.xyz/generative/api/trait", 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "RANDOM_FUNC_SCRIPT";
        tx = await p.set(contract, key, '<script id="snippet-random-code" type="text/javascript">let seed=window.location.href.split("/").find(e=>e.includes("i0"));if(null==seed){let e="0123456789abcdefghijklmnopqrstuvwsyz";seed=new URLSearchParams(window.location.search).get("seed")||Array(64).fill(0).map($=>e[Math.random()*e.length|0]).join("")+"i0"}else{let $="seed=";for(let l=0;l<seed.length-$.length;++l)if(seed.substring(l,l+$.length)==$){seed=seed.substring(l+$.length);break}}function cyrb128(e){let $=1779033703,l=3144134277,t=1013904242,n=2773480762;for(let i=0,_;i<e.length;i++)$=l^Math.imul($^(_=e.charCodeAt(i)),597399067),l=t^Math.imul(l^_,2869860233),t=n^Math.imul(t^_,951274213),n=$^Math.imul(n^_,2716044179);return $=Math.imul(t^$>>>18,597399067),l=Math.imul(n^l>>>22,2869860233),t=Math.imul($^t>>>17,951274213),n=Math.imul(l^n>>>19,2716044179),[($^l^t^n)>>>0,(l^$)>>>0,(t^$)>>>0,(n^$)>>>0]}function sfc32(e,$,l,t){return function(){l>>>=0,t>>>=0;var n=(e>>>=0)+($>>>=0)|0;return e=$^$>>>9,$=l+(l<<3)|0,l=(l=l<<21|l>>>11)+(n=n+(t=t+1|0)|0)|0,(n>>>0)/4294967296}}let mathRand=sfc32(...cyrb128(seed));</script>', 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        /**
         * For royalty second sale
         */
        key = "OWNER_ROYALTY_SECOND_SALE"; // percent split from royalty second sale for owner of project
        tx = await p.setUInt256(contract, key, 9000, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        /**
         * Marketplace
         */
        key = "MARKETPLACE_BENEFIT_PERCENT";
        tx = await p.setUInt256(contract, key, 250, 0);
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

        key = "c2.min.js@1.0.0"
        tx = await p.set(contract, key, `<script type="text/javascript" src="https://cdn.generative.xyz/ajax/libs/c2/1.0.0/c2.min.js"></script>`, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "chromajs@2.4.2"
        tx = await p.set(contract, key, `<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/chroma-js/2.4.2/chroma.min.js"></script>`, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "p5.grain.js@0.6.1"
        tx = await p.set(contract, key, `<script type="text/javascript" src="https://cdn.generative.xyz/ajax/libs/p5.grain/0.6.1/p5.grain.min.js"></script>`, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        // GEN Token
        key = "GEN_TOKEN";
        tx = await p.setAddress(contract, key, `0xf3627926495E0C8Edb9Ca05e700e0f7C90F74b71`, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);

        key = "TEAM_VESTING"; // address hold core team's GENToken as a vesting contract
        tx = await p.setAddress(contract, key, `0xBBE8C699018176576Dd10176fCfedAB0a5386a29`, 0);
        console.log("set ", key);
        console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();