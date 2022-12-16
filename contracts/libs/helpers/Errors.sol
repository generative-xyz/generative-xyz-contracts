// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.12;

library Errors {
    enum ReturnCode {
        SUCCESS,
        FAILED
    }

    string public constant SUCCESS = "0";

    address public constant ZERO_ADDR = address(0x0);

    // common errors
    string public constant INV_ADD = "100";
    string public constant ONLY_ADMIN_ALLOWED = "101";
    string public constant ONLY_CREATOR = "102";

    // validation error
    string public constant MISSING_NAME = "200";
    string public constant INV_FEE_PROJECT = "201";
    string public constant INV_PROJECT = "202";
    string public constant REACH_MAX = "203";
    string public constant INV_PARAMS = "204";
    string public constant SEED_INV = "205";
    string public constant SEED_INV_1 = "206";
    string public constant SEED_INV_2 = "207";
    string public constant INV_BOILERPLATE_ADD = "208";
    string public constant TOO_HIGH = "209";
    string public constant TOKEN_HAS_SEED = "210";
    string public constant ZERO_SEED = "211";
    string public constant OPENING_SCHEDULE = "212";
}