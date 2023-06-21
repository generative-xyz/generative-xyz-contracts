import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import {SoulGmDao} from "./soulGmDao";

(async () => {
    try {
        if (process.env.NETWORK != "mumbai") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2);
        const contract = args[0];
        const dao = new SoulGmDao(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        let a: any = {};
        a._quorumVote = await dao._quorumVote(contract);
        a.quorumVotes = await dao.quorumVotes(contract);
        a._admin = await dao._admin(contract);
        a._votingToken = await dao._votingToken(contract);
        a._paramAddr = await dao._paramAddr(contract);
        a._proposalThreshold = await dao._proposalThreshold(contract);
        a.proposalThreshold = await dao.proposalThreshold(contract);
        a.votingDelay = await dao.votingDelay(contract);
        a.votingPeriod = await dao.votingPeriod(contract);
        console.log({a});
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();