import { CryptoAIData } from "./cryptoAIData";
import { initConfig } from "./index";
// @ts-ignore
import { DNA, ELEMENT, KEY_DNA, PALETTE_COLOR, TRAITS_DNA } from "./data";
import * as data from "./datajson/data-compressed.json";

async function main() {
  if (process.env.NETWORK != "base_mainnet") {
    console.log("wrong network");
    return;
  }

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

    data.elements.Body.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Body element - Name: ${data.elements.Body.names[index]}, Trait: ${data.elements.Body.traits[index]}`
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
    data.DNA.Dog.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Dog DNA - Name: ${data.DNA.Dog.names[index]}, Trait: ${data.DNA.Dog.traits[index]}`
        );
      }
    });

    data.DNA.Cat.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Cat DNA - Name: ${data.DNA.Cat.names[index]}, Trait: ${data.DNA.Cat.traits[index]}`
        );
      }
    });

    data.DNA.Frog.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Frog DNA - Name: ${data.DNA.Frog.names[index]}, Trait: ${data.DNA.Frog.traits[index]}`
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

    data.DNA.Human.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Human DNA - Name: ${data.DNA.Human.names[index]}, Trait: ${data.DNA.Human.traits[index]}`
        );
      }
    });

    data.DNA.Monkey.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null)) {
        throw new Error(
          `Null position found in Monkey DNA - Name: ${data.DNA.Monkey.names[index]}, Trait: ${data.DNA.Monkey.traits[index]}`
        );
      }
    });

    //ADD DNA
    await dataContract.addDNA(address, 0, KEY_DNA, TRAITS_DNA);
    //ADD DNA Variant
    await dataContract.addDNAVariant(
      address,
      0,
      DNA.DOG,
      data.DNA.Dog.names,
      data.DNA.Dog.traits,
      data.DNA.Dog.positions
    );
    await dataContract.addDNAVariant(
      address,
      0,
      DNA.CAT,
      data.DNA.Cat.names,
      data.DNA.Cat.traits,
      data.DNA.Cat.positions
    );
    await dataContract.addDNAVariant(
      address,
      0,
      DNA.FROG,
      data.DNA.Frog.names,
      data.DNA.Frog.traits,
      data.DNA.Frog.positions
    );
    await dataContract.addDNAVariant(
      address,
      0,
      DNA.HUMAN,
      data.DNA.Human.names,
      data.DNA.Human.traits,
      data.DNA.Human.positions
    );
    await dataContract.addDNAVariant(
      address,
      0,
      DNA.MONKEY,
      data.DNA.Monkey.names,
      data.DNA.Monkey.traits,
      data.DNA.Monkey.positions
    );
    await dataContract.addDNAVariantRobot(
      address,
      0,
      data.DNA.Robot.names,
      data.DNA.Robot.traits
    );
    await dataContract.addDNAVariantRobotPosition(
      address,
      0,
      data.DNA.Robot.positions.slice(0, 5),
      0,
      5
    );
    await dataContract.addDNAVariantRobotPosition(
      address,
      0,
      data.DNA.Robot.positions.slice(5, 10),
      5,
      10
    );

    await dataContract.addItem(
      address,
      0,
      ELEMENT.BODY,
      data.elements.Body.names,
      data.elements.Body.traits,
      data.elements.Body.positions
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
  } catch (error) {
    console.log("Error checking positions:", error);
    throw error;
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
