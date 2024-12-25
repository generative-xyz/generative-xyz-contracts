import { promises as fs } from "fs";
import { CryptoAIData } from "./cryptoAIData";
import { initConfig } from "./index";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();
    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    const address = config["dataContractAddress"];

    const args = process.argv.slice(2);
    if (args.length == 0) {
        console.log("missing number")
        return;
    }

    const num = parseInt(args[0]);

    // Keep original duplicate checking
    const attrsChecked: string[] = [];
    const attrsDuplicated = [];

    // Add rarity tracking
    const attributeCounts: { [key: string]: { [key: string]: { counter: number; percent: number } } } = {};
    let totalTokens = 0;

    const arts: any[] = [];
    for (let i = 1; i <= num; i++) {
        try {
            console.log(i, " checking");
            const attr = await dataContract.getAttrData(address, i);
            const attrStr = JSON.stringify(attr);
            totalTokens++;

            // Original duplicate check
            if (attrsChecked.includes(attrStr)) {
                const duplicateIndex = attrsChecked.indexOf(attrStr);
                const duplicateId = duplicateIndex + 1;
                attrsDuplicated.push({
                    id: i,
                    attr,
                    duplicateOf: {
                        id: duplicateId,
                        attr: JSON.parse(attrsChecked[duplicateIndex])
                    }
                });
                console.log(`Found duplicate attr for ID ${i}:`, attr);
                console.log(`Duplicate of ID ${duplicateId}:`, JSON.parse(attrsChecked[duplicateIndex]));
            }
            attrsChecked.push(attrStr);

            const art: any = {};
            // Add rarity tracking
            const attributes = JSON.parse(attr);
            attributes.forEach((attribute: any) => {
                const { trait_type: trait, value } = attribute;
              

                if (!attributeCounts[trait]) {
                    attributeCounts[trait] = {};
                }

                if (!attributeCounts[trait][value]) {
                    attributeCounts[trait][value] = {
                        counter: 0,
                        percent: 0
                    };
                }

                if (trait !== 'attributes') {
                    art[trait] = value;
                }
                attributeCounts[trait][value].counter++;
                attributeCounts[trait][value].percent = Number(((attributeCounts[trait][value].counter / totalTokens) * 100).toFixed(2));
            });
            arts.push(art);

        } catch (ex) {
            console.log(i, " failed");
            break;
        }
    }

    // Write duplicates file
    const duplicatesPath = "migrations/data/cryptoai/datajson/duplicates.json";
    console.log("Writing duplicates to:", duplicatesPath);
    console.log("Total items checked:", attrsChecked.length);
    console.log("Total duplicates found:", attrsDuplicated.length);
    await fs.writeFile(duplicatesPath, JSON.stringify(attrsDuplicated, null, 2));

    // Calculate and write rarity percentages
    const rarityData: { [key: string]: { [key: string]: { percent: number, counter: number } } } = {};
    
    Object.entries(attributeCounts).forEach(([trait, values]) => {
        rarityData[trait] = {};
        Object.entries(values).forEach(([value, data]) => {
            rarityData[trait][value] = {
                percent: data.percent,
                counter: data.counter
            };
        });
    });

    const rarityPath = "migrations/data/cryptoai/datajson/data-rarity.json";
    console.log("Writing rarity data to:", rarityPath);
    console.log("Total tokens analyzed:", totalTokens);
    await fs.writeFile(rarityPath, JSON.stringify(rarityData, null, 2));


    const path = "./migrations/data/cryptoai/datajson/data-arts.json";
    console.log("Writing arts data to:", path);
    await fs.writeFile(path, JSON.stringify(arts, null, 2));
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});
