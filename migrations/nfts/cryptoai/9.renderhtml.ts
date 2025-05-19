import { promises as fs } from "fs";
import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";

async function main() {
  // if (process.env.NETWORK != "local") {
  //     console.log("wrong network");
  //     return;
  // }

  let config = await initConfig();
  const args = process.argv.slice(2);
  if (args.length == 0) {
    console.log("missing number");
    return;
  }
  const dataContract = new CryptoAI(
    process.env.NETWORK,
    process.env.PRIVATE_KEY,
    process.env.PUBLIC_KEY
  );
  let htmls = "";
  for (let i = 1; i <= parseInt(args[0]); i++) {
    const data = await dataContract.tokenURI(config.contractAddress, i);
    const json = JSON.parse(data);
    htmls += "<span>" + i + "</span><br>" + parseSVGData(json.image) + "<br>";
    console.log(i, " processed");
  }
  const path = "./migrations/nfts/cryptoai/testhtml.html";
  await fs.writeFile(path, htmls);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

function parseSVGData(dataURI: string): any {
  const svgData = decodeURIComponent(dataURI.split(",")[1]);
  // const tempDiv = document.createElement("div");
  // tempDiv.innerHTML = svgData;
  return svgData;
}
