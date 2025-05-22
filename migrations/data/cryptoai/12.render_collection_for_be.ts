import { promises as fs } from "fs";

async function main() {
  const collections = require("./datajson/collections.json");

  const data = [];
  try {

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

  const dataTraits: any = {};

  collections.forEach((collection: any) => {
    const elements = collection.name[1];

    if (!dataTraits[collection.name[0]]) {
          dataTraits[collection.name[0]] = {
          counter: 1,
          percent: calculatePercentage(1, collections.length)
        };
    } else {
      dataTraits[collection.name[0]].counter++;
      dataTraits[collection.name[0]].percent = calculatePercentage(
        dataTraits[collection.name[0]].counter,
        collections.length
      );
    }

    elements.forEach((element: string, index: number) => {


      if (index === 0) return;
      
      const elementKey = element || 'Null';
      const traitKey = getTraitKey(index);
      
      if (!dataTraits[traitKey]) {
        dataTraits[traitKey] = {};
      }

      if (!dataTraits[traitKey][elementKey]) {
        dataTraits[traitKey][elementKey] = {
          counter: 1,
          percent: calculatePercentage(1, collections.length),
          name: elementKey
        };
      } else {
        dataTraits[traitKey][elementKey].counter++;
        dataTraits[traitKey][elementKey].percent = calculatePercentage(
          dataTraits[traitKey][elementKey].counter,
          collections.length
        );
      }
    });
  });
    
    // console.log('____dataTraits', dataTraits);
    for (let i = 0; i < collections.length; i++) {
      const collection = collections[i];
      const traits = collection['name'][1];
      const name = collection['name'][0];

      const attrNumber = traits.filter((t: string) => t !== '').length - 1;

      let rarity = attrNumber > 0 ? 1 : 0;//dataTraits[name].percent;

      // console.log('___DNA', rarity, dataTraits[name]);
    
      const ttrs: any = [
        {
          trait_type: 'Attributes',
          value: attrNumber
        },
        {
          trait_type: 'DNA',
          value: traits[0],
          
        },
              
      ]

      if (traits[1] !== '') {
        ttrs.push({
          trait_type: 'Collar',
          value: traits[1],
          rarity: dataTraits['collar'][traits[1]].percent
        })

        rarity *= dataTraits['collar'][traits[1]].percent;
        // console.log('___collar', rarity, dataTraits['collar'][traits[1]]);
      }
      if (traits[2] !== '') {
        ttrs.push({
          trait_type: 'Head',
          value: traits[2],
          rarity: dataTraits['head'][traits[2]].percent
        })

        rarity *= dataTraits['head'][traits[2]].percent;
        // console.log('___head', rarity, dataTraits['head'][traits[2]]);
      }
      if (traits[3] !== '') {
        ttrs.push({
          trait_type: 'Eyes',
          value: traits[3],
          rarity: dataTraits['eyes'][traits[3]].percent
        })

        rarity *= dataTraits['eyes'][traits[3]].percent;
        // console.log('___eyes', rarity, dataTraits['eyes'][traits[3]]);
      }
      if (traits[4] !== '') {
        ttrs.push({
          trait_type: 'Mouth',
          value: traits[4],
          rarity: dataTraits['mouth'][traits[4]].percent
        })

        rarity *= dataTraits['mouth'][traits[4]].percent;
        // console.log('___mouth', rarity, dataTraits['mouth'][traits[4]]);
      }
      if (traits[5] !== '') {
        ttrs.push({
          trait_type: 'Earring',
          value: traits[5],
          rarity: dataTraits['earring'][traits[5]].percent
        })

        rarity *= dataTraits['earring'][traits[5]].percent;
        // console.log('___earring', rarity, dataTraits['earring'][traits[5]]);
      }


      let weight = 1;
      switch (name) {
        case 'Kong':
          weight = 1000;
          break;
        case 'X-Type':
          weight = 100000;
          break;
        case 'Neo-Human':
          weight = 10000000;
          break;
        case 'Robot':
          weight = 1000000000;
          break;
      }
   
          

      data.push({
        id: collection['id'],
        name: name,
        DNA_Rarity: dataTraits[name].percent,
        thumbnail: `https://cdn.eternalai.org/homepage/data-mint-v2/${collection['id']}.svg`,
        trait: ttrs,
        rarity: weight + rarity
      })
    }

   data.sort((a, b) => a.rarity - b.rarity);

    await fs.writeFile(
      "migrations/data/cryptoai/datajson/collections_nfs_be.json",
      JSON.stringify(data, null, 2),
      "utf8"
    );
    console.log("Successfully wrote rarity data to collections_nfs_be.json");
  } catch (error) {
    console.error("Error writing rarity data to file:", error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
