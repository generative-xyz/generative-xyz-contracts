import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeNFT} from "./GenerativeNFT";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const contract = '0x301aF137c7bFD869ad9Da646afa8a8015B83E6Dc';
        const nft = new GenerativeNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const tokenId = 1;
        let a: any = {};
        // a.getTokenURI = await nft.getTokenURI(contract, tokenId);
        // a.get_boilerplateAdd = await nft.get_boilerplateAddr(contract);
        // a.get_boilerplateId = await nft.get_boilerplateId(contract);
        // a.get_paramsValues = await nft.get_paramsValues(contract, tokenId);
        a.getTraits = await nft.getTraits(contract);
        a.getMax = await nft.getMax(contract);
        a.getLimit = await nft.getLimit(contract);
        // a.getTokenTraits = await nft.getTokenTraits(contract, tokenId);
        console.log(a);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();