import { promises as fs } from "fs";
import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";

async function generateRandomData(startSeed: number, endSeed: number): Promise<any[]> {
    const mintData: any[] = [];
    const data = require('../../data/cryptoai/datajson/data-compressed.json');

    // Get the total number of DNA types
    const totalDNATypes = Object.keys(data.DNA).length;

    for (let i = startSeed; i <= endSeed; i++) {
        try {
            // Generate a unique seed for each attribute using prime numbers to avoid patterns
            const dnaSeed = consistentSeed(i * 31);
            const dnaTypeSeed = consistentSeed(i * 53);
            const mouthSeed = consistentSeed(i * 37);
            const headSeed = consistentSeed(i * 41);
            const eyesSeed = consistentSeed(i * 43);
            const bodySeed = consistentSeed(i * 47);

            const indexDNA = traitsDNA(data.DNA, dnaSeed);
            
            // Get the DNA key at this index
            const dnaKey = Object.keys(data.DNA)[indexDNA];
            // Get lengths for all arrays
            const dnaTypeLength = data.DNA[dnaKey].names.length;
            const mouthLength = data.elements.Mouth.names.length;
            const headLength = data.elements.Head.names.length;
            const eyesLength = data.elements.Eyes.names.length;
            const bodyLength = data.elements.Body.names.length;

        
            // Calculate all indices safely within bounds
            const indexNameDNAType = traitsElement(data.DNA[dnaKey].traits, dnaTypeSeed);
            const indexNameMouth = traitsElement(data.elements.Mouth.traits, mouthSeed);
            const indexNameHead = traitsElement(data.elements.Head.traits, headSeed);
            const indexNameEyes = traitsElement(data.elements.Eyes.traits, eyesSeed);
            const indexNameBody = traitsElement(data.elements.Body.traits, bodySeed);

         
            // Validate indices
            if (indexNameDNAType >= dnaTypeLength || 
                indexNameMouth >= mouthLength ||
                indexNameHead >= headLength ||
                indexNameEyes >= eyesLength ||
                indexNameBody >= bodyLength) {
                console.log(`Warning: Invalid indices detected for id ${i}:`);
                console.log(`DNAType: ${indexNameDNAType}/${dnaTypeLength}`);
                console.log(`Mouth: ${indexNameMouth}/${mouthLength}`);
                console.log(`Head: ${indexNameHead}/${headLength}`);
                console.log(`Eyes: ${indexNameEyes}/${eyesLength}`);
                console.log(`Body: ${indexNameBody}/${bodyLength}`);
                continue;
            }


            const randomDataIndex = [
                indexDNA,
                [indexNameDNAType, indexNameBody, indexNameHead, indexNameEyes, indexNameMouth]
            ];

            const randomData = [
                dnaKey,
                [data.DNA[dnaKey].names[indexNameDNAType], data.elements.Body.names[indexNameBody], data.elements.Head.names[indexNameHead], data.elements.Eyes.names[indexNameEyes], data.elements.Mouth.names[indexNameMouth]]
            ];
          
            mintData.push({
                id: i,
                data: randomData,
                dataIndex: randomDataIndex
            });

            if (i % 100 === 0) {
                console.log(`Generated ${i} entries...`);
            }

        } catch (ex) {
            console.log(`Failed to generate data for seed ${i}:`, ex);
            continue;
        }
    }
    return mintData;
}

async function checkDuplicateData(mintData: any[]): Promise<{hasDuplicates: boolean, duplicateIds: Set<number>}> {
    try {
        // Create a map to store data strings and their occurrences
        const dataMap = new Map<string, number[]>();
        const duplicateIds = new Set<number>();

        // Process each entry
        mintData.forEach((entry: any) => {
            const dataStr = JSON.stringify(entry.data);
            if (!dataMap.has(dataStr)) {
                dataMap.set(dataStr, [entry.id]);
            } else {
                dataMap.get(dataStr)?.push(entry.id);
                // Mark all instances of this duplicate for regeneration
                dataMap.get(dataStr)?.forEach(id => duplicateIds.add(id));
            }
        });

        // Check for duplicates and report
        let hasDuplicates = false;
        let totalDuplicates = 0;

        dataMap.forEach((ids, dataStr) => {
            if (ids.length > 1) {
                hasDuplicates = true;
                totalDuplicates += ids.length - 1;
                console.log(`\nDuplicate found for data: ${dataStr}`);
                console.log(`Occurs in entries with IDs: ${ids.join(', ')}`);
            }
        });

        // Print summary
        if (hasDuplicates) {
            console.log(`\nTotal duplicates found: ${totalDuplicates}`);
            console.log(`Unique combinations: ${dataMap.size}`);
            console.log(`Total entries: ${mintData.length}`);
        } else {
            console.log('\nNo duplicates found!');
            console.log(`Total unique entries: ${mintData.length}`);
        }

        return { hasDuplicates, duplicateIds };
    } catch (error) {
        console.error('Error checking duplicates:', error);
        return { hasDuplicates: false, duplicateIds: new Set() };
    }
}

async function generateUniqueRandomData(totalArtGen: number): Promise<any[]> {
    let mintData = await generateRandomData(1, totalArtGen);
    let attempt = 1;
    let { hasDuplicates, duplicateIds } = await checkDuplicateData(mintData);
    
    while (hasDuplicates) {
        console.log(`\nAttempt ${attempt + 1}: Regenerating ${duplicateIds.size} duplicate entries...`);
        
        // Regenerate only the duplicate entries with new seeds
        const maxSeed = Math.max(...mintData.map(entry => entry.id));
        let newSeed = maxSeed + 1;
        
        // Replace duplicate entries with new random data
        mintData = await Promise.all(mintData.map(async entry => {
            if (duplicateIds.has(entry.id)) {
                const newData = await generateRandomData(newSeed, newSeed);
                newSeed++;
                return {
                    ...entry,
                    data: newData[0].data
                };
            }
            return entry;
        }));
        
        // Check for duplicates again
        const result = await checkDuplicateData(mintData);
        hasDuplicates = result.hasDuplicates;
        duplicateIds = result.duplicateIds;
        attempt++;
        
        // Safety check to prevent infinite loops
        if (attempt > 10) {
            console.log('\nWarning: Maximum attempts reached. Some duplicates may remain.');
            break;
        }
    }
    
    console.log(`\nFinished generating unique data after ${attempt} attempt(s)`);
    return mintData;
}

async function main() {
    // if (process.env.NETWORK != "base_mainnet") {
    //     console.log("wrong network");
    //     return;
    // }

    let config = await initConfig();
    const args = process.argv.slice(2);
    if (args.length == 0) {
        console.log("missing number")
        return;
    }

    const num = parseInt(args[0]);
    
    try {
        console.log("Generating random entries...");
        const mintData = await generateUniqueRandomData(1, num);
        console.log(`Successfully generated ${mintData.length} unique entries`);

        const rarityPath = "migrations/data/cryptoai/datajson/data-mint.json";
        await fs.writeFile(rarityPath, JSON.stringify(mintData, null, 2));
        console.log(`Data saved to ${rarityPath}`);

        const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);

        const data = require('../../data/cryptoai/datajson/data-mint.json');
        for (const entry of data) {
            console.log(entry.dataIndex[0], entry.dataIndex[1]);
            await dataContract.mint(
                config.contractAddress, 0, process.env.PUBLIC_KEY, process.env.PUBLIC_KEY,
                entry.dataIndex[0],
                entry.dataIndex[1]
            );
        }

    } catch (error) {
        console.error("Error generating data:", error);
        process.exitCode = 1;
    }
}

function randomValueIndexArrayInt(hash: number, lenArray: number): number {
  return hash % lenArray
}

function cyrb128(str: string): number[] {
  let h1 = 1779033703,
    h2 = 3144134277,
    h3 = 1013904242,
    h4 = 2773480762
  for (let i = 0, k; i < str.length; i++) {
    k = str.charCodeAt(i)
    h1 = h2 ^ Math.imul(h1 ^ k, 597399067)
    h2 = h3 ^ Math.imul(h2 ^ k, 2869860233)
    h3 = h4 ^ Math.imul(h3 ^ k, 951274213)
    h4 = h1 ^ Math.imul(h4 ^ k, 2716044179)
  }
  h1 = Math.imul(h3 ^ (h1 >>> 18), 597399067)
  h2 = Math.imul(h4 ^ (h2 >>> 22), 2869860233)
  h3 = Math.imul(h1 ^ (h3 >>> 17), 951274213)
  h4 = Math.imul(h2 ^ (h4 >>> 19), 2716044179)
  return [(h1 ^ h2 ^ h3 ^ h4) >>> 0, (h2 ^ h1) >>> 0, (h3 ^ h1) >>> 0, (h4 ^ h1) >>> 0]
}

function sfc32_c(a: number, b: number, c: number, d: number): number {
  a >>>= 0
  b >>>= 0
  c >>>= 0
  d >>>= 0
  let t = (a + b) | 0
  a = b ^ (b >>> 9)
  b = (c + (c << 3)) | 0
  c = (c << 21) | (c >>> 11)
  d = (d + 1) | 0
  t = (t + d) | 0
  c = (c + t) | 0
  return (t >>> 0) / 4294967296
}

function consistentRand(seed: number, l: number, r: number): number {
  const hash = cyrb128(seed.toString());
  const rand = sfc32_c(hash[0], hash[1], hash[2], hash[3]);
  return l + rand * (r - l);
}

function consistentSeed(seed: number): number {
  const hash = cyrb128(seed.toString());
  return sfc32_c(hash[0], hash[1], hash[2], hash[3]);
}

function getRandomBool(seed: number, l: any, r: any): any {
  const hash = cyrb128(seed.toString());
  const rand = sfc32_c(hash[0], hash[1], hash[2], hash[3]);
  return rand < 0.5 ? l : r;
}

function modifyColor(inColor: any, rate: number): any {
  return inColor
}

function traits(arrAttrs: [string, number][], seed: number): [string, number] {
  let trs: number[] = []
  let indexMin = 0

  for (let i = 0; i < arrAttrs.length; i++) {
    indexMin += arrAttrs[i][1]
    trs[i] = indexMin
  }

  const ftrs = Math.floor(consistentRand(seed, 0, indexMin))
  for (let i = 0; i < trs.length; i++) {
    if (ftrs < trs[i]) {
      return arrAttrs[i]
    }
  }
  return arrAttrs[0]; // Default return to satisfy TypeScript
}

function traitsDNA(arrAttrs: {trait: number, names: string[], positions: number[]}[], seed: number): number {
  let trs: number[] = []
  let indexMin = 0

  for (let i = 0; i < arrAttrs.length; i++) {
    indexMin += Number(arrAttrs[i].trait)
    trs[i] = indexMin
  }

  const ftrs = Math.floor(consistentRand(seed, 0, indexMin))
  for (let i = 0; i < trs.length; i++) {
    if (ftrs < trs[i]) {
      return i
    }
  }
  return 0; // Default return to satisfy TypeScript
}

function traitsElement(arrAttrs: number[], seed: number): number {
  let trs: number[] = []
  let indexMin = 0

  for (let i = 0; i < arrAttrs.length; i++) {
    indexMin += Number(arrAttrs[i])
    trs[i] = indexMin
  }

  const ftrs = Math.floor(consistentRand(seed, 0, indexMin))
  for (let i = 0; i < trs.length; i++) {
    if (ftrs < trs[i]) {
      return i
    }
  }
  return 0; // Default return to satisfy TypeScript
}


main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});