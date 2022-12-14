import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenerativeBoilerplateNFT} from "./GenerativeBoilerplateNFT";
import * as fs from "fs";
import {candyProject2} from "./projectTemplates";
import {createAlchemyWeb3} from "@alch/alchemy-web3";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }

        const nft = new GenerativeBoilerplateNFT(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);


        const contract = '0x0bf438e43dc76fac0758764745c3153361ea484b';
        const projectTemplate = candyProject2;
        const uri = "data:application/json;base64," + btoa(JSON.stringify({
            name: projectTemplate.name,
            description: projectTemplate.description,
            image: projectTemplate.image,
            animation_url: projectTemplate.animation_url,
        })) // Base64 encode the String
        // let scriptContent = fs.readFileSync(projectTemplate.script)
        // const hardhatConfig = require("../../../hardhat.config");
        // const web3 = createAlchemyWeb3(hardhatConfig.networks[hardhatConfig.defaultNetwork].url);
        // const seed = web3.utils.leftPad(web3.utils.asciiToHex(""), 64);
        const tx = await nft.mintProject2(
                contract, process.env.PUBLIC_KEY,
                projectTemplate.name,
                projectTemplate.maxMint,
                projectTemplate.notOwnerLimit,
                // scriptContent.toString(),
                projectTemplate.scriptType,
                projectTemplate.clientSeed,
                uri,
                ethers.utils.parseEther(projectTemplate.fee),
                projectTemplate.feeTokenAddr,
                JSON.parse(JSON.stringify(projectTemplate.params)),
                0
            )
        ;
        console.log("tx:", tx);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();