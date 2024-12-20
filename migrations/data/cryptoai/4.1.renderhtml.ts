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

    // Render HTML
    const args = process.argv.slice(2);
    if (args.length == 0) {
        console.log("missing number")
        return;
    }
    let htmls = "";
    const num = parseInt(args[0]);
    for (var i = 1; i <= num; i++) {
        try {
            const fullHtml = await dataContract.cryptoAIImageHtml(address, i);
            htmls += "<span>" + i + "</span><br><iframe src='" + fullHtml + "'></iframe><br>"
            console.log(i, " processed");
        } catch (ex) {
            console.log(i, " failed");
        }
    }
    const path = "./migrations/data/cryptoai/testhtml.html";
    console.log("path", path);
    await fs.writeFile(path, htmls);

}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});

