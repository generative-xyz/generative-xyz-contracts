import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {TrustlessPhotos} from "./photos";

(async () => {
    try {
        if (process.env.NETWORK != "tc_testnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const nft = new TrustlessPhotos(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        // a.linkPhoto = await nft.linkPhoto(contract, 1);
        // a.listAlbums = await nft.listAlbums(contract);
        // a.listAlbumPhotos = await nft.listAlbumPhotos(contract, "");
        // a.listPhotos = await nft.listPhotos(contract);
        // a.countPhotos = await nft.countPhotos(contract);
        // a.countAlbums = await nft.countAlbums(contract);
        // a.countAlbumPhotos = await nft.countAlbumPhotos(contract, "");
        // a.tokenURI = await nft.tokenURI(contract, args[1]);
        a.download = await nft.download(contract, args[1]);
        a.download = nft.aesDec(a.download, "abc123");
        console.log({a});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();