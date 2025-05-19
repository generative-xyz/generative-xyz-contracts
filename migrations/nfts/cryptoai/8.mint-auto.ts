import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";

async function main() {
  let config = await initConfig();
  const args = process.argv.slice(2);

  try {
    const dataContract = new CryptoAI(
      process.env.NETWORK,
      process.env.PRIVATE_KEY,
      process.env.PUBLIC_KEY
    );

    const data = require("../../data/cryptoai/datajson/collections.json");
    let index = 0;

    if (args.length == 0) {
      for (const entry of data) {
        index++;
        await dataContract.mint(
          config.contractAddress,
          0,
          process.env.PUBLIC_KEY,
          process.env.PUBLIC_KEY,
          entry.index[0],
          entry.index[1]
        );
        console.log("index", index);
      }
    } else {
      for (let i = 0; i <= parseInt(args[0]); i++) {
        await dataContract.mint(
          config.contractAddress,
          0,
          process.env.PUBLIC_KEY,
          process.env.PUBLIC_KEY,
          data[i].index[0],
          data[i].index[1]
        );
        console.log("index", i);
      }
    }
  } catch (error) {
    console.error("Error generating data:", error);
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
