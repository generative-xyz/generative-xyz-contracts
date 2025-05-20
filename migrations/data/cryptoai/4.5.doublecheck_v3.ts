import { promises as fs } from "fs";

async function main() {
  const collections = require("./datajson/collections.json");

  const data = [];

  try {

    for(let i = 0; i < collections.length; i++) {
      const collection = collections[i];
      const traits = collection['name'][1];
      const name = collection['name'][0];
    
      const ttrs = [
        {
          trait_type: 'Attributes',
          value: traits.filter((t:string) => t !== '').length
        },
        {
          trait_type: 'DNA',
          value: traits[0]
        },
              
      ]

      if(traits[1] !== '') {
        ttrs.push({
          trait_type: 'Collar',
          value: traits[1]
        })
      }
      if(traits[2] !== '') {
        ttrs.push({
          trait_type: 'Head',
          value: traits[2]
        })
      }
      if(traits[3] !== '') {
        ttrs.push({
          trait_type: 'Eyes',
          value: traits[3]
        })
      }
      if(traits[4] !== '') {
        ttrs.push({
          trait_type: 'Mouth',
          value: traits[4]
        })
      }
      if(traits[5] !== '') {
        ttrs.push({
          trait_type: 'Earring',
          value: traits[5]
        })
      }

      data.push({
        id: collection['id'],
        name: name,
        thumbnail: `https://cdn.eternalai.org/homepage/data-mint/${collection['id']}.svg`,
        trait: ttrs
      })
    }

    await fs.writeFile(
      "migrations/data/cryptoai/datajson/check-rarity-be.json",
      JSON.stringify(data, null, 2),
      "utf8"
    );
    console.log("Successfully wrote rarity data to check-rarity-be.json");
  } catch (error) {
    console.error("Error writing rarity data to file:", error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
