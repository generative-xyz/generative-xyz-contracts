import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {GenDAO} from "./gendao";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const dao = new GenDAO(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        a.quorumVotes = await dao.quorumVotes(contract);
        a._admin = await dao._admin(contract);
        a._votingToken = await dao._votingToken(contract);
        a._paramAddr = await dao._paramAddr(contract);
        console.log({a});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();