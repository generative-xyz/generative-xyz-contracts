/*import fs from 'fs'
var data = JSON.parse(fs.readFileSync('./datajson/data-compressed.json', 'utf-8'))*/

import * as data from "./datajson/data-compressed.json";

export enum ELEMENT {
  EARRING = "Earring",
  MOUTH = "Mouth",
  EYES = "Eyes",
  HEAD = "Head",
  COLLAR = "Collar",
}

const DATA_ELEMENTS_1 = [
  {
    ele_type: ELEMENT.COLLAR,
    names: data.elements.Collar.names,
    rarities: data.elements.Collar.traits,
    positions: data.elements.Collar.positions,
  },

  {
    ele_type: ELEMENT.HEAD,
    names: data.elements.Head.names,
    rarities: data.elements.Head.traits,
    positions: data.elements.Head.positions,
  },
  {
    ele_type: ELEMENT.EYES,
    names: data.elements.Eyes.names,
    rarities: data.elements.Eyes.traits,
    positions: data.elements.Eyes.positions,
  },
];

const DATA_ELEMENTS_2 = [
  {
    ele_type: ELEMENT.MOUTH,
    names: data.elements.Mouth.names,
    rarities: data.elements.Mouth.traits,
    positions: data.elements.Mouth.positions,
  },
  {
    ele_type: ELEMENT.EARRING,
    names: data.elements.Earring.names,
    rarities: data.elements.Earring.traits,
    positions: data.elements.Earring.positions,
  },
];

export enum DNA {
  ALIEN = "Alien",
  KONG = "Kong",
  X_TYPE = "X-Type",
  NEO_HUMAN = "Neo-Human",
  ROBOT = "Robot",
}

const KEY_DNA = [DNA.ALIEN, DNA.KONG, DNA.X_TYPE, DNA.NEO_HUMAN, DNA.ROBOT];
const TRAITS_DNA = [
  data.DNA.Alien.trait,
  data.DNA.Kong.trait,
  data.DNA["X-Type"].trait,
  data.DNA["Neo-Human"].trait,
  data.DNA.Robot.trait,
].map((item) => Number(item));

const PALETTE_COLOR = data.palette;

export { DATA_ELEMENTS_1, DATA_ELEMENTS_2, KEY_DNA, PALETTE_COLOR, TRAITS_DNA };
