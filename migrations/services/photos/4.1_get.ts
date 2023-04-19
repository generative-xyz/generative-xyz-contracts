import * as dotenv from 'dotenv';
import {ethers} from "ethers";
import {TrustlessPhotos} from "./photos";
import * as buffer from "buffer";
import {fileTypeFromBuffer} from "file-type";

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

        a.countAlbums = await nft.countAlbums(contract);
        a.listAlbums = await nft.listAlbums(contract);
        a.countAlbumPhotos = await nft.countAlbumPhotos(contract, "album2");
        a.listAlbumPhotos = await nft.listAlbumPhotos(contract, "album2");

        a.countPhotos = await nft.countPhotos(contract);
        a.listPhotos = await nft.listPhotos(contract);
        a.linkPhoto = await nft.linkPhoto(contract, a.listAlbumPhotos[0]);

        // a.tokenURI = await nft.tokenURI(contract, a.listAlbumPhotos[0]);

        const chunks = await nft.download(contract, a.listAlbumPhotos[0]);
        let buffers = Buffer.from("");
        for (let i = 0; i < chunks.length; i++) {
            const encrypted = ethers.utils.arrayify(chunks[0]);
            const decrypted = nft.aesDec(encrypted, "abc123");
            buffers = Buffer.concat([buffers, decrypted]);
        }
        const bt = require('buffer-type');
        const info = bt(buffers);
        const data = "data:" + info?.type + ";base64," + buffers.toString("base64");
        console.log({a}, data);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();