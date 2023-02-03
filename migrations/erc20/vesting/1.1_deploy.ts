import * as dotenv from 'dotenv';
import {Gentokenvesting} from "./gentokenvesting";


(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const gentokenvesting = new Gentokenvesting(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const address = await gentokenvesting.deployUpgradeable(
            process.env.PUBLIC_KEY,
            [process.env.PUBLIC_KEY, '0xF61234046A18b07Bf1486823369B22eFd2C4507F'],
            [1, 1],
            '0xf3627926495E0C8Edb9Ca05e700e0f7C90F74b71'
        );
        console.log("%s GENToken Vesting address: %s", process.env.NETWORK, address);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();