import {initConfig} from "./index";
import {CryptoAIData} from "./cryptoAIData";
import {promises as fs} from "fs";

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
    for (var i = 1; i <= num; i++) {
        try {
            const fullSVG = await dataContract.cryptoAIImageSvg(address, i);
            images += "<span>" + i + "</span><br>" + "<img width=\"64\" src=\"" + fullSVG + "\" title='" + i + "' />"
            console.log(i, " processed image");
            const attr = await dataContract.cryptoAIAttributes(address, i);
            images += "<pre>" + attr + "</pre>";
            const attrval = await dataContract.cryptoAIAttributesValue(address, i);
            images += "<pre style='color: red'>" + attrval + "</pre><br>";
            console.log(i, " processed attr");
        } catch (ex) {
            console.log(i, " failed");
            break;
        }
    }
    const path = "./migrations/data/cryptoai/testimage.html";
    console.log("path", path);
    await fs.writeFile(path, images);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});

