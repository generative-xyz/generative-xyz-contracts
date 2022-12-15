import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeNFT2} from "./GenerativeNFT2";
import {candyTraits} from "./projectTraits";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const contract = '0x301aF137c7bFD869ad9Da646afa8a8015B83E6Dc';
        const nft = new GenerativeNFT2(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tx = await nft.mint(contract, 0);
        console.log(tx);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();