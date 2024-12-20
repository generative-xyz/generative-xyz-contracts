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
    MONKEY = 'Monkey',
    CAT = 'Cat',
    DOG = 'Dog',
    FROG = 'Frog',
    ROBOT = 'Robot',
    HUMAN = 'Human',
}

const KEY_DNA = [DNA.CAT, DNA.DOG, DNA.FROG, DNA.ROBOT, DNA.HUMAN, DNA.MONKEY]
const TRAITS_DNA = [data.DNA.Cat.trait, data.DNA.Dog.trait, data.DNA.Frog.trait, data.DNA.Robot.trait, data.DNA.Human.trait,data.DNA.Monkey.trait].map((item) => Number(item))

const DATA_DNA_VARIANT_1 = [
    {
        ele_type: DNA.DOG,
        names: data.DNA.Dog.names,
        rarities: data.DNA.Dog.traits,
        positions: data.DNA.Dog.positions,
    },
    {
        ele_type: DNA.CAT,
        names: data.DNA.Cat.names,
        rarities: data.DNA.Cat.traits,
        positions: data.DNA.Cat.positions,
    },
]

const DATA_DNA_VARIANT_2 = [
    {
        ele_type: DNA.ROBOT,
        names: data.DNA.Robot.names,
        rarities: data.DNA.Robot.traits,
        positions: data.DNA.Robot.positions,
    },
    {
        ele_type: DNA.FROG,
        names: data.DNA.Frog.names,
        rarities: data.DNA.Frog.traits,
        positions: data.DNA.Frog.positions,
    },
]


const DATA_DNA_VARIANT_3 = [
    {
        ele_type: DNA.HUMAN,
        names: data.DNA.Human.names,
        rarities: data.DNA.Human.traits,
        positions: data.DNA.Human.positions,
    },
    {
        ele_type: DNA.MONKEY,
        names: data.DNA.Monkey.names,
        rarities: data.DNA.Monkey.traits,
        positions: data.DNA.Monkey.positions,
    },
]

const PALLET_COLOR = data.palette;

export { KEY_DNA, TRAITS_DNA, DATA_ELEMENTS_1, DATA_ELEMENTS_2, DATA_DNA_VARIANT_1, DATA_DNA_VARIANT_2, DATA_DNA_VARIANT_3, PALLET_COLOR }
