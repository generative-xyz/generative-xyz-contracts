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
        const contract = '0x1b17150fba9820b4ef6e7617451564d925a54ec5';
        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await nft.setCustomURI(contract, 1, "https://rove-rendering-dev.moshwithme.io/api/v1/rendered-nft/80001/0xe579276f0c0532e8fd2f43292b9eedf1ca5222c3/10/1", 0);
        console.log(tx);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();