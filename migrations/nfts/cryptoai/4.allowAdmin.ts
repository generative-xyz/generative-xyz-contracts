import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";

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
  // Add address of user want to mint
  await dataContract.allowAdmin(
    config.contractAddress,
    0,
    process.env.PUBLIC_KEY,
    true
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
