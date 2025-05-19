import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";
const data = require("../../data/cryptoai/datajson/collections.json");

async function main() {
  // if (process.env.NETWORK != "base_mainnet") {
  //     console.log("wrong network");
  //     return;
  // }

  let config = await initConfig();

  const dataContract = new CryptoAI(
    process.env.NETWORK,
    process.env.PRIVATE_KEY,
    process.env.PUBLIC_KEY
  );
  await dataContract.mint(
    config.contractAddress,
    0,
    process.env.PUBLIC_KEY,
    process.env.PUBLIC_KEY,
    data[0].index[0],
    data[0].index[1]
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
