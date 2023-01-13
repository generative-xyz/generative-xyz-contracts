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
            "Generative.XYZ-DAO",
            process.env.PUBLIC_KEY,
            "0x47B528E9eDD8f7Dd709bCa9f7E45c499C85eccfb",
            "0x4fB7B3039C630bF191C2A3933Bb4ba221a93C45B",
            "0x0000000000000000000000000000000000000000"
        );
        console.log("%s GENToken address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();