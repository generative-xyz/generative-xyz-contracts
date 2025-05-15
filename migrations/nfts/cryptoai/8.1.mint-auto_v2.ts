import { promises as fs } from "fs";
import * as dataCompress from "../../data/cryptoai/datajson/data-compressed.json";
const dropTraitValue = 0.95;
const rageTriggerDrop = 450;
function generateRandomData(
  data: any,
  indexGen: number,
  indexDNA: number,
  rageDNA: number
): { name: any; index: any } {
  const dnaTypeSeed = consistentSeed(indexGen * 503);
  const mouthSeed = consistentSeed(indexGen * 3007);
  const headSeed = consistentSeed(indexGen * 40001);
  const eyesSeed = consistentSeed(indexGen * 400003);
  const bodySeed = consistentSeed(indexGen * 40000007);

  // const indexDNA = traitsDNA(data.DNA, dnaSeed);

  const dnaKey = Object.keys(data.DNA)[indexDNA];
  try {
    const indexNameDNAType = traitsElement(
      data.DNA[dnaKey].traits,
      dnaTypeSeed,
      -1
    );
    const indexNameMouth = traitsElement(
      data.elements.Mouth.traits,
      mouthSeed,
      rageDNA
    );
    const indexNameHead = traitsElement(
      data.elements.Head.traits,
      headSeed,
      rageDNA
    );
    const indexNameEyes = traitsElement(
      data.elements.Eyes.traits,
      eyesSeed,
      rageDNA
    );
    const indexNameBody = traitsElement(
      data.elements.Body.traits,
      bodySeed,
      rageDNA
    );

    const randomDataIndex = [
      indexDNA,
      [
        indexNameDNAType,
        indexNameBody,
        indexNameHead,
        indexNameEyes,
        indexNameMouth,
      ],
    ];

    const randomData = [
      dnaKey,
      [
        data.DNA[dnaKey].names[indexNameDNAType],
        data.elements.Body.names[indexNameBody],
        data.elements.Head.names[indexNameHead],
        data.elements.Eyes.names[indexNameEyes],
        data.elements.Mouth.names[indexNameMouth],
      ],
    ];

    return {
      name: randomData,
      index: randomDataIndex,
    };
  } catch (error) {
    console.log("____error", dnaKey, data.DNA[dnaKey].traits);
    // return;
  }

  return {
    name: [],
    index: [],
  };
}

function checkDublicateArt(data_mintings: any[], data: any): boolean {
  return data_mintings.some(
    (item) =>
      `${item.name.toString()}_${item.index.toString()}` ===
      `${data.name.toString()}_${data.index.toString()}`
  );
}

async function main() {
  // let config = await initConfig();
  const args = process.argv.slice(2);
  if (args.length == 0) {
    console.log("missing number");
    return;
  }

  const num = parseInt(args[0]);

  const data_mintings = [];
  let indexArt = 1;
  let indexSeed = 1;
  let indexDNA = 0;
  let startRageDNA = 300;
  let stuckRangDNA = 0;

  try {
    while (indexArt <= num) {
      const keyDNA = Object.keys(dataCompress.DNA)[indexDNA];
      // const rageDNA = dataCompress.DNA[keyDNA].rageDNA;
      startRageDNA = MathMap(indexArt + stuckRangDNA, 1, num, 300, 1000);

      console.log("__rageDNA", startRageDNA);
      let data = generateRandomData(
        dataCompress,
        indexSeed,
        indexDNA,
        startRageDNA
      );
      indexSeed++;

      if (checkDublicateArt(data_mintings, data)) {
        console.log("____dublicate", indexArt);
        stuckRangDNA += 1;
        continue;
      }

      dataCompress.DNA[keyDNA].trait--;
      if (dataCompress.DNA[keyDNA].trait == 0) {
        indexDNA++;
      }

      if (dataCompress.DNA[keyDNA].traits[data.index[1][0]] < rageTriggerDrop) {
        dataCompress.DNA[keyDNA].traits[data.index[1][0]] *= dropTraitValue;
      }

      if (
        dataCompress.elements.Earring.traits[data.index[1][1]] < rageTriggerDrop
      ) {
        dataCompress.elements.Earring.traits[data.index[1][1]] *=
          dropTraitValue;
      }

      if (
        dataCompress.elements.Head.traits[data.index[1][2]] < rageTriggerDrop
      ) {
        dataCompress.elements.Head.traits[data.index[1][2]] *= dropTraitValue;
      }

      if (
        dataCompress.elements.Eyes.traits[data.index[1][3]] < rageTriggerDrop
      ) {
        dataCompress.elements.Eyes.traits[data.index[1][3]] *= dropTraitValue;
      }

      if (
        dataCompress.elements.Mouth.traits[data.index[1][4]] < rageTriggerDrop
      ) {
        dataCompress.elements.Mouth.traits[data.index[1][4]] *= dropTraitValue;
      }

      console.log("procresss", indexArt);
      data_mintings.push(data);
      console.log("process", indexArt);
      indexArt++;
    }
    console.log("duplicates", indexSeed, data_mintings.length);

    const collectionPath = "migrations/data/cryptoai/datajson/collections.json";
    await fs.writeFile(collectionPath, JSON.stringify(data_mintings, null, 2));
  } catch (error) {
    console.error("Error generating data:", error);
    process.exitCode = 1;
  }
}

function randomValueIndexArrayInt(hash: number, lenArray: number): number {
  return hash % lenArray;
}

function cyrb128(str: string): number[] {
  let h1 = 1779033703,
    h2 = 3144134277,
    h3 = 1013904242,
    h4 = 2773480762;
  for (let i = 0, k; i < str.length; i++) {
    k = str.charCodeAt(i);
    h1 = h2 ^ Math.imul(h1 ^ k, 597399067);
    h2 = h3 ^ Math.imul(h2 ^ k, 2869860233);
    h3 = h4 ^ Math.imul(h3 ^ k, 951274213);
    h4 = h1 ^ Math.imul(h4 ^ k, 2716044179);
  }
  h1 = Math.imul(h3 ^ (h1 >>> 18), 597399067);
  h2 = Math.imul(h4 ^ (h2 >>> 22), 2869860233);
  h3 = Math.imul(h1 ^ (h3 >>> 17), 951274213);
  h4 = Math.imul(h2 ^ (h4 >>> 19), 2716044179);
  return [
    (h1 ^ h2 ^ h3 ^ h4) >>> 0,
    (h2 ^ h1) >>> 0,
    (h3 ^ h1) >>> 0,
    (h4 ^ h1) >>> 0,
  ];
}

function sfc32_c(a: number, b: number, c: number, d: number): number {
  a >>>= 0;
  b >>>= 0;
  c >>>= 0;
  d >>>= 0;
  let t = (a + b) | 0;
  a = b ^ (b >>> 9);
  b = (c + (c << 3)) | 0;
  c = (c << 21) | (c >>> 11);
  d = (d + 1) | 0;
  t = (t + d) | 0;
  c = (c + t) | 0;
  return (t >>> 0) / 4294967296;
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
  return inColor;
}

function traits(arrAttrs: [string, number][], seed: number): [string, number] {
  let trs: number[] = [];
  let indexMin = 0;

  for (let i = 0; i < arrAttrs.length; i++) {
    indexMin += arrAttrs[i][1];
    trs[i] = indexMin;
  }

  const ftrs = Math.floor(consistentRand(seed, 0, indexMin));
  for (let i = 0; i < trs.length; i++) {
    if (ftrs < trs[i]) {
      return arrAttrs[i];
    }
  }
  return arrAttrs[0];
}

function traitsDNA(
  arrAttrs: { trait: number; names: string[]; positions: number[] }[],
  seed: number
): number {
  let trs: number[] = [];
  let indexMin = 0;

  for (let i = 0; i < arrAttrs.length; i++) {
    indexMin += Number(arrAttrs[i].trait);
    trs[i] = indexMin;
  }

  const ftrs = Math.floor(consistentRand(seed, 0, indexMin));
  for (let i = 0; i < trs.length; i++) {
    if (ftrs < trs[i]) {
      return i;
    }
  }
  return 0;
}

function traitsElement(
  arrAttrs: number[],
  seed: number,
  rageDNA: number
): number {
  let trs: number[] = [];
  let indexMin = 0;

  for (let i = 0; i < arrAttrs.length; i++) {
    if (rageDNA < arrAttrs[i] && rageDNA != -1) {
      indexMin += 0;
    } else {
      indexMin += Number(arrAttrs[i]);
    }
    trs[i] = indexMin;
  }

  const ftrs = Math.floor(consistentRand(seed, 0, indexMin));
  for (let i = 0; i < trs.length; i++) {
    if (ftrs < trs[i]) {
      return i;
    }
  }
  return 0;
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

function MathMap(
  x: number,
  a: number,
  b: number,
  c: number,
  d: number
): number {
  return parseFloat((((x - a) * (d - c)) / (b - a) + c).toFixed(3));
}
