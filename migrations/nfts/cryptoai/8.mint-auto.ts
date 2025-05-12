import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";

async function main() {
  let config = await initConfig();

  try {
    const dataContract = new CryptoAI(
      process.env.NETWORK,
      process.env.PRIVATE_KEY,
      process.env.PUBLIC_KEY
    );

    const data = require("../../data/cryptoai/datajson/collections.json");
    for (const entry of data) {
      console.log(entry.name[0], entry.name[1]);
      await dataContract.mint(
        config.contractAddress,
        0,
        process.env.PUBLIC_KEY,
        process.env.PUBLIC_KEY,
        entry.index[0],
        entry.index[1]
      );
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
