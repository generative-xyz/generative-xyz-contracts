import { CryptoAIData } from "./cryptoAIData";
import { initConfig } from "./index";
// @ts-ignore
import { DNA, ELEMENT, KEY_DNA, PALETTE_COLOR, TRAITS_DNA } from "./data";
import * as data from "./datajson/data-compressed.json";

async function main() {
  //   if (process.env.NETWORK != "base_testnet") {
  //     console.log("wrong network");
  //     return;
  //   }

  try {
    let configaaa = await initConfig();

    const dataContract = new CryptoAIData(
      process.env.NETWORK,
      process.env.PRIVATE_KEY,
      process.env.PUBLIC_KEY
    );

    //ADD Element
    const address = configaaa["dataContractAddress"];

    //Add palettes Color
    await dataContract.setPalettes(address, 0, PALETTE_COLOR);

    // Check positions for each element
    data.elements.Mouth.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Mouth element - Name: ${data.elements.Mouth.names[index]}, Trait: ${data.elements.Mouth.traits[index]}`
        );
      }
    });

    data.elements.Earring.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Earring element - Name: ${data.elements.Earring.names[index]}, Trait: ${data.elements.Earring.traits[index]}`
        );
      }
    });

    data.elements.Eyes.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Eyes element - Name: ${data.elements.Eyes.names[index]}, Trait: ${data.elements.Eyes.traits[index]}`
        );
      }
    });

    data.elements.Head.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Head element - Name: ${data.elements.Head.names[index]}, Trait: ${data.elements.Head.traits[index]}`
        );
      }
    });

    // Check positions for each DNA variant

    data.DNA.Alien.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Alien DNA - Name: ${data.DNA.Alien.names[index]}, Trait: ${data.DNA.Alien.traits[index]}`
        );
      }
    });

    data.DNA.Kong.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Kong DNA - Name: ${data.DNA.Kong.names[index]}, Trait: ${data.DNA.Kong.traits[index]}`
        );
      }
    });

    data.DNA.Robot.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Robot DNA - Name: ${data.DNA.Robot.names[index]}, Trait: ${data.DNA.Robot.traits[index]}`
        );
      }
    });

    data.DNA["Neo-Human"].positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Human DNA - Name: ${data.DNA["Neo-Human"].names[index]}, Trait: ${data.DNA["Neo-Human"].traits[index]}`
        );
      }
    });

    data.DNA.Kong.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null)) {
        throw new Error(
          `Null position found in Kong DNA - Name: ${data.DNA.Kong.names[index]}, Trait: ${data.DNA.Kong.traits[index]}`
        );
      }
    });

    //ADD DNA
    await dataContract.addDNA(address, 0, KEY_DNA, TRAITS_DNA);
    console.log("add item TRAITS_DNA", TRAITS_DNA);
    //ADD DNA Variant
    await dataContract.addDNAVariant(
      address,
      0,
      DNA.ALIEN,
      data.DNA.Alien.names,
      data.DNA.Alien.traits,
      data.DNA.Alien.positions
    );
    await dataContract.addDNAVariant(
      address,
      0,
      DNA.KONG,
      data.DNA.Kong.names,
      data.DNA.Kong.traits,
      data.DNA.Kong.positions
    );
    await dataContract.addDNAVariant(
      address,
      0,
      DNA.X_TYPE,
      data.DNA["X-Type"].names,
      data.DNA["X-Type"].traits,
      data.DNA["X-Type"].positions
    );
    await dataContract.addDNAVariant(
      address,
      0,
      DNA.NEO_HUMAN,
      data.DNA["Neo-Human"].names,
      data.DNA["Neo-Human"].traits,
      data.DNA["Neo-Human"].positions
    );

    await dataContract.addDNAVariant(
      address,
      0,
      DNA.ROBOT,
      data.DNA.Robot.names,
      data.DNA.Robot.traits,
      data.DNA.Robot.positions
    );

    // await dataContract.addDNAVariantRobot(
    //   address,
    //   0,
    //   data.DNA.Robot.names,
    //   data.DNA.Robot.traits,
    //   data.DNA.Robot.positions
    // );
    // console.log("add item DNA Robot 2");
    // await dataContract.addDNAVariantRobotPosition(
    //   address,
    //   0,
    //   data.DNA.Robot.positions.slice(0, 5),
    //   0,
    //   5
    // );
    // // console.log("add item DNA Robot 3");
    // await dataContract.addDNAVariantRobotPosition(
    //   address,
    //   0,
    //   data.DNA.Robot.positions.slice(5, 10),
    //   5,
    //   10
    // );
    await dataContract.addItem(
      address,
      0,
      ELEMENT.COLLAR,
      data.elements.Collar.names,
      data.elements.Collar.traits,
      data.elements.Collar.positions
    );
    await dataContract.addItem(
      address,
      0,
      ELEMENT.HEAD,
      data.elements.Head.names,
      data.elements.Head.traits,
      data.elements.Head.positions
    );
    await dataContract.addItem(
      address,
      0,
      ELEMENT.EYES,
      data.elements.Eyes.names,
      data.elements.Eyes.traits,
      data.elements.Eyes.positions
    );
    await dataContract.addItem(
      address,
      0,
      ELEMENT.MOUTH,
      data.elements.Mouth.names,
      data.elements.Mouth.traits,
      data.elements.Mouth.positions
    );
    await dataContract.addItem(
      address,
      0,
      ELEMENT.EARRING,
      data.elements.Earring.names,
      data.elements.Earring.traits,
      data.elements.Earring.positions
    );
  } catch (error) {
    console.log("Error checking positions:", error);
    throw error;
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
