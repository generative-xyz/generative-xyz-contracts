import * as dotenv from 'dotenv';
import {GenDAO} from "./gendao";


(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const genDAO = new GenDAO(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await genDAO.deployUpgradeable(
            "Generative.XYZ-DAO Devnet",
            process.env.PUBLIC_KEY,
            "0x47B528E9eDD8f7Dd709bCa9f7E45c499C85eccfb",
            "0xf3627926495E0C8Edb9Ca05e700e0f7C90F74b71"
        );
        console.log("%s GENT Dao address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();