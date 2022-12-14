import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeNFT} from "./GenerativeNFT";
import {candyTraits} from "./projectTraits";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const contract = '0xdec70044399547d5997ebf900c07c9d3c68467d4';
        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const traits = candyTraits;
        const tx = await nft.updateTraits(contract, JSON.parse(JSON.stringify({
            _traits: traits,
        })), 0);
        console.log(tx);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();