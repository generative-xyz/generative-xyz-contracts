import { promises as fs } from "fs";

async function main() {
  const collections = require("./datajson/collections.json");

  const data: any = {};
  const attrs: any = {};
  for (let i = 0; i < collections.length; i++) {
    const collection = collections[i];
    // if(!data[collection.name[0]]){
    //   data[collection.name[0]] = {
    //     counter: 1,
    //     percent:  Number(
    //   ((1 / collections.length) * 100).toFixed(2)
    // )
    //   }
    // } else {
    //   data[collection.name[0]].counter++;
    //    data[collection.name[0]].percent = Number(
    //   ((data[collection.name[0]].counter / collections.length) * 100).toFixed(2)
    // );
    // }

    const elements = collection.name[1];
    const elements_remove_empty = elements.filter(
      (element: any) => element !== ""
    );
    const attr_key = "attr_" + elements_remove_empty.length;
    if (!attrs[attr_key]) {
      attrs[attr_key] = 1;
    } else {
      attrs[attr_key]++;
    }

    elements.forEach((element: any, index: number) => {
      const el_key = element === "" ? "empty" : element;
      const pr_key =
        index === 0
          ? "dna"
          : index === 1
          ? "body"
          : index === 2
          ? "head"
          : index === 3
          ? "eyes"
          : index === 4
          ? "mouth"
          : "unknown";
      if (!data[pr_key]) {
        data[pr_key] = {};
      }
      if (!data[pr_key][el_key]) {
        data[pr_key][el_key] = {
          counter: 1,
          percent: Number(((1 / collections.length) * 100).toFixed(2)),
        };
      } else {
        data[pr_key][el_key].counter++;
        data[pr_key][el_key].percent = Number(
          ((data[pr_key][el_key].counter / collections.length) * 100).toFixed(2)
        );
      }
    });
  }

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
