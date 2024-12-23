const fs = require('fs').promises;

type ConfigField = 'contractAddress' | 'dataContractAddress';
let config = {
    "contractAddress": "0x9E545E3C0baAB3E08CdfD552C960A1050f373042",
    "dataContractAddress": "0x610178dA211FEF7D417bC0e6FeD39F05609AD788"
};

async function initConfig() {
    config = JSON.parse((await fs.readFile('./config.json')).toString());
    console.log("initConfig", config)
    return config;
}

async function updateConfig(key: ConfigField, value: string) {
    if (key in config) {
        config[key] = value;
        console.log("config ------ ", config);
        return fs.writeFile('./config.json', JSON.stringify(config, null, 2));
    }
}

export { initConfig, updateConfig };

