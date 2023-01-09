pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract GENToken is ERC20Upgradeable {
    function initialize(
        string memory name,
        string memory symbol
    ) initializer public {
        __ERC20_init(name, symbol);
    }
}
