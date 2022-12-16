import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {createAlchemyWeb3} from "@alch/alchemy-web3";
import {GenerativeProject} from "./generativeProject";
import dayjs = require("dayjs");

(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }

        const nft = new GenerativeProject(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)

        const contract = args[0];
        const tx = await nft.mint(
                contract,
                JSON.parse(JSON.stringify({
                    _maxSupply: 100,
                    _limit: 95,
                    _mintPrice: ethers.utils.parseEther("0.002"),
                    _mintPriceAddr: "0x0000000000000000000000000000000000000000",
                    _name: "Test",
                    _creator: "Dev team",
                    _creatorAddr: process.env.PUBLIC_KEY,
                    _license: "MIT",
                    _desc: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                    _image: "ipfs://QmZha95v86iME98rpxrJWbHerK3JjEHKkiGpdS4NgZKjdb",
                    _social: JSON.parse(JSON.stringify({
                        _web: "https://generative.xyz",
                        _twitter: "https://twitter.com/thaibao56",
                        _discord: "https://discord.com/channels/123/123",
                        _medium: "",
                        _instagram: "",
                    })),
                    _scriptType: JSON.parse(JSON.stringify(["p5js@1.5.0", "tonejs@14.8.49"])),
                    _scripts: [`<script>document.addEventListener("DOMContentLoaded",function(){var e;let n=mathRand();window.$generativeTraits={T1:(e=n)>.5},console.log(window.$generativeTraits);document.getElementById("container-el").innerHTML="<span>tokenId: "+tokenId+"</span><br><span>tokenMintNumber: "+tokenMintNumber+"</span><br><span>project: "+projectNumber+"</span><br><span>seed: "+seed+"</span><br>"});</script>`],
                    _styles: "body {}div#container-el {}",
                    _completeTime: 0,
                    _genNFTAddr: '0x0000000000000000000000000000000000000000',
                    _itemDesc: "[Item] Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
                })),
                [process.env.PUBLIC_KEY],
                false,
                dayjs().add(1, "hour").unix(),
                "0.001",
                0
            )
        ;
        console.log("tx:", tx?.transactionHash, tx?.status);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();