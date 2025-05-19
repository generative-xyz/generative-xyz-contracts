import { promises as fs } from "fs";
import * as path from "path";
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

  const outputDir = "./migrations/nfts/cryptoai/data-mint";
  // Ensure the directory exists
  await fs.mkdir(outputDir, { recursive: true });

  for (let i = 1; i <= parseInt(args[0]); i++) {
    const data = await dataContract.tokenURI(config.contractAddress, i);
    const json = JSON.parse(data);
    const svgContent = parseSVGData(json.image);
    const filePath = path.join(outputDir, `${i}.svg`);
    await fs.writeFile(filePath, svgContent, "utf8");
    console.log(`Token ${i} processed and saved to ${filePath}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

function parseSVGData(dataURI: string): string {
  // data:image/svg+xml;utf8,<svg ...>
  // or data:image/svg+xml;utf8,%3Csvg...
  // or data:image/svg+xml;base64,...
  if (dataURI.startsWith("data:image/svg+xml;base64,")) {
    const base64 = dataURI.split(",")[1];
    return Buffer.from(base64, "base64").toString("utf8");
  } else if (dataURI.startsWith("data:image/svg+xml;utf8,")) {
    return decodeURIComponent(dataURI.split(",")[1]);
  } else {
    // fallback
    return dataURI;
  }
}
