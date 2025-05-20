import { promises as fs } from "fs";

async function main() {
  const collections = require("./datajson/collections.json");

  interface TraitData {
    counter: number;
    percent: number;
  }

  interface TraitStats {
    [key: string]: {
      [key: string]: TraitData;
    };
  }

  interface AttributeStats {
    [key: string]: number;
  }

  const calculatePercentage = (count: number, total: number): number => 
    Number(((count / total) * 100).toFixed(2));

  const getTraitKey = (index: number): string => {
    const traitMap: { [key: number]: string } = {
      0: 'dna',
      1: 'collar',
      2: 'head',
      3: 'eyes',
      4: 'mouth',
      5: 'earring',
    };
    return traitMap[index] || 'unknown';
  };

  const data: TraitStats = {};
  const attrs: any = {};

  collections.forEach((collection: any) => {
    const elements = collection.name[1];
    const nonEmptyElements = elements.filter((element: string) => element !== '');
    const attrKey = `attr_${nonEmptyElements.length - 1}`;
    
    if (!attrs[attrKey]) {
      attrs[attrKey] = {
        counter: 0,
        collections: []
      }
    }
    attrs[attrKey].counter++;
    attrs[attrKey].collections.push({id: collection['id'], attr: collection.name, thumbnail: `https://cdn.eternalai.org/homepage/data-mint-v2/${collection['id']}.svg`});

    elements.forEach((element: string, index: number) => {
      const elementKey = element || 'Null';
      const traitKey = getTraitKey(index);
      
      if (!data[traitKey]) {
        data[traitKey] = {};
      }

      if (!data[traitKey][elementKey]) {
        data[traitKey][elementKey] = {
          counter: 1,
          percent: calculatePercentage(1, collections.length)
        };
      } else {
        data[traitKey][elementKey].counter++;
        data[traitKey][elementKey].percent = calculatePercentage(
          data[traitKey][elementKey].counter,
          collections.length
        );
      }
    });
  });

  const print = {
    attributes: attrs,
    traits: data,
  };
  // Write rarity data to JSON file
  try {
    await fs.writeFile(
      "migrations/data/cryptoai/datajson/check-rarity.json",
      JSON.stringify(print, null, 2),
      "utf8"
    );
    console.log("Successfully wrote rarity data to check-rarity.json");
  } catch (error) {
    console.error("Error writing rarity data to file:", error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
