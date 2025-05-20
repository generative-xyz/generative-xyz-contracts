import { promises as fs } from 'fs';
import { ELEMENT } from "../../data/cryptoai/data";

const dataCompress = require("./../../data/cryptoai/datajson/data-compressed.json");

const inputAlien = require("./../../data/cryptoai/datajson/input/alien.json");
const inputKong = require("./../../data/cryptoai/datajson/input/kong.json");
const inputXType = require("./../../data/cryptoai/datajson/input/x-type.json");
const inputNeoHuman = require("./../../data/cryptoai/datajson/input/neo_human_output_swapped.json");
const inputRobot = require("./../../data/cryptoai/datajson/input/robot_nft_output_swapped.json");



function generateRandomData(
  indexDNA: number,
  keyDNA: string,
  renderInputDate: string[],
  index_dna_type: number
): { name: any; index: any } {

  

  try {
    
    const indexNameHead = dataCompress.elements[ELEMENT.HEAD].names.findIndex((name: string) => name === renderInputDate[0]);
    const indexNameMouth = dataCompress.elements[ELEMENT.MOUTH].names.findIndex((name: string) => name === renderInputDate[1]);
    const indexNameEyes  = dataCompress.elements[ELEMENT.EYES].names.findIndex((name: string) => name === renderInputDate[2]);
    const indexNameEarring = dataCompress.elements[ELEMENT.EARRING].names.findIndex((name: string) => name === renderInputDate[3]);
    const indexNameCollar = dataCompress.elements[ELEMENT.COLLAR].names.findIndex((name: string) => name === renderInputDate[4]);

    if(indexNameHead === -1 || indexNameMouth === -1 || indexNameEyes === -1 || indexNameEarring === -1 || indexNameCollar === -1) {
      console.log('___errorname', renderInputDate, {
        head: indexNameHead,
        mouth: indexNameMouth,
        eyes: indexNameEyes,
        earring: indexNameEarring,
        collar: indexNameCollar,
      });
    }
    const randomDataIndex = [
      indexDNA,
      [
        index_dna_type,
        indexNameCollar,
        indexNameHead,
        indexNameEyes,
        indexNameMouth,
        indexNameEarring,
      ],
    ];

    const randomData = [
      keyDNA,
      [
        dataCompress.DNA[keyDNA].names[index_dna_type],
        dataCompress.elements[ELEMENT.COLLAR].names[indexNameCollar],
        dataCompress.elements[ELEMENT.HEAD].names[indexNameHead],
        dataCompress.elements[ELEMENT.EYES].names[indexNameEyes],
        dataCompress.elements[ELEMENT.MOUTH].names[indexNameMouth],
        dataCompress.elements[ELEMENT.EARRING].names[indexNameEarring],
      ],
    ];

    return {
      name: randomData,
      index: randomDataIndex,
    };
  } catch (error) {
    console.log("____error 22323232", error);
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

  const dataInputRender: any = {
    'Alien': inputAlien,
    'Kong': inputKong,
    'X-Type': inputXType,
    'Neo-Human': inputNeoHuman,
    'Robot': inputRobot,
  }


  const data_mintings: any[] = [];
  let indexArt = 1;
  let index_input_render = 0;
  let key_input_render = Object.keys(dataInputRender);
  let key_dna_compress_data = Object.keys(dataCompress.DNA).sort();
  let index_dna_type = 0;
  let index_dna_type_index = 0;
  

  try {
    while (index_input_render < key_input_render.length) {

      const keyDNA = key_input_render[index_input_render];

      if(keyDNA === 'Neo-Human' || keyDNA === 'Robot') {
        const dataRender = dataInputRender[keyDNA][index_dna_type];
        index_dna_type_index = dataCompress.DNA[keyDNA].names.findIndex((item: any) => item === dataRender[0]);
        dataInputRender[keyDNA][index_dna_type] = dataInputRender[keyDNA][index_dna_type].slice(1);
      } else {
        index_dna_type_index = index_dna_type % dataCompress.DNA[keyDNA].names.length;
      }
      
      
      let data = generateRandomData(
         key_dna_compress_data.findIndex((item: any) => item === keyDNA),
         keyDNA,
         dataInputRender[keyDNA][index_dna_type],
         index_dna_type_index
      );
      
      dataCompress.DNA[keyDNA].trait -= 1;
      index_dna_type++;

      if(dataCompress.DNA[keyDNA].trait === 0) {
        index_input_render++;
        index_dna_type = 0;
      }
       
      console.log("procresss", indexArt);
      data_mintings.push({ id: indexArt, ...data });
      indexArt++;

    }

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

function traitsElement(
  arrAttrs: number[],
  seed: number
): number {
  let trs: number[] = [];
  let indexMin = 0;

  for (let i = 0; i < arrAttrs.length; i++) {
      indexMin += Number(arrAttrs[i]);
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
