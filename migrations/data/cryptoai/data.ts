/*import fs from 'fs'
var data = JSON.parse(fs.readFileSync('./datajson/data-compressed.json', 'utf-8'))*/

import * as data from './datajson/data-compressed.json'

export enum ELEMENT {
    BODY = 'Body',
    MOUTH = 'Mouth',
    EYES = 'Eyes',
    HEAD = 'Head',
}

const DATA_ELEMENTS_1 = [
    {
        ele_type: ELEMENT.BODY,
        names: data.elements.Body.names,
        rarities: data.elements.Body.traits,
        positions: data.elements.Body.positions,
    },
    {
        ele_type: ELEMENT.MOUTH,
        names: data.elements.Mouth.names,
        rarities: data.elements.Mouth.traits,
        positions: data.elements.Mouth.positions,
    },
    {
        ele_type: ELEMENT.EYES,
        names: data.elements.Eyes.names,
        rarities: data.elements.Eyes.traits,
        positions: data.elements.Eyes.positions,
    },
]

const DATA_ELEMENTS_2 = [
    {
        ele_type: ELEMENT.HEAD,
        names: data.elements.Head.names,
        rarities: data.elements.Head.traits,
        positions: data.elements.Head.positions,
    },
]

export enum DNA {
    APE = 'Ape',
    CAT = 'Cat',
    DOG = 'Dog',
    FROG = 'Frog',
    ROBOT = 'Robot',
    HUMAN = 'Human',
}

const KEY_DNA = [DNA.CAT, DNA.DOG, DNA.FROG, DNA.ROBOT, DNA.HUMAN, DNA.APE]
const TRAITS_DNA = [data.DNA.Cat.trait, data.DNA.Dog.trait, data.DNA.Frog.trait, data.DNA.Robot.trait, data.DNA.Human.trait,data.DNA.Ape.trait].map((item) => Number(item))

const PALETTE_COLOR = data.palette;

export { KEY_DNA, TRAITS_DNA, DATA_ELEMENTS_1, DATA_ELEMENTS_2, PALETTE_COLOR }
