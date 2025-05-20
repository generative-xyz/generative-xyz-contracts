import { promises as fs } from "fs";

function checkDuplicateArt(data2Check: any[], data: any): boolean {
  return data2Check.some(
    (item) =>
      `${item.name.toString()}_${item.index.toString()}` ===
      `${data.name.toString()}_${data.index.toString()}`
  );
}

async function main() {
  const collections = require("./datajson/collections.json");

  const data2Check: any[] = [];
  const duplicate: any[] = [];

  let counter = 0;
  try {

    for(let i = 0; i < collections.length; i++) {
      const collection = collections[i];


      console.log('____progress', i + 1);
      if (checkDuplicateArt(data2Check, collection)) {

        console.log('____duplicate', counter);

        const tt= [collection.name[1][1],
          collection.name[1][2],
          collection.name[1][3],
          collection.name[1][4],
          collection.name[1][0]]
        duplicate.push(tt);
        counter++;
        continue;
      }
      data2Check.push(collection);
    }


    const fsc = {
     counter: counter,
     data: duplicate
   }

    await fs.writeFile(
      "migrations/data/cryptoai/datajson/collections-duplicate.json",
      JSON.stringify(fsc, null, 2),
      "utf8"
    );
    console.log("Successfully wrote rarity data to collections-duplicate.json");
  } catch (error) {
    console.error("Error writing rarity data to file:", error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
