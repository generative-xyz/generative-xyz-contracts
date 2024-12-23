import {initConfig} from "./index";
import {CryptoAIData} from "./cryptoAIData";
import {promises as fs} from "fs";
import * as data from "./datajson/data-rarity.json";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();
    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    //ADD Element
    const address = config["dataContractAddress"];
    // console.log(await dataContract.getDNA(address));
    // console.log(await dataContract.getItem(address, "Body"));
    // return;
    // Render SVG
    const args = process.argv.slice(2);
    if (args.length == 0) {
        console.log("missing number")
        return;
    }
    let images = "";
    const num = parseInt(args[0]);
    let traits = "";
    for (var i = 1; i <= num; i++) {
        try {
            const fullSVG = await dataContract.cryptoAIImageSvg(address, i);
            images += "<span>" + i + "</span><br>" + "<img width=\"64\" src=\"" + fullSVG + "\" title='" + i + "' />"
            console.log(i, " processed image");
            let attr = await dataContract.getAttrData(address, i);
            let attrFormat = [...JSON.parse(attr)];
            for (let j = 0; j < attrFormat.length; j++) {
                const value = attrFormat[j]["value"];
                const rarity = Object.keys(data.undefined).find(key => key === value);
                const dataRarity = (data as any).undefined[`${rarity}`];
                attrFormat[j]["rarity"] = dataRarity;
            }
            attr = JSON.stringify(attrFormat);
            images += "<pre>" + attr + "</pre><br>";
            traits += `${attr},`;
        } catch (ex) {
            console.log(i, " failed");
            break;
        }
    }
    const path = "./migrations/data/cryptoai/testimage.html";
    const pathJson = "./migrations/data/cryptoai/datajson/data-traits.json";
    console.log("path", path);
    await fs.writeFile(path, images);
    await fs.writeFile(pathJson, traits);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});

