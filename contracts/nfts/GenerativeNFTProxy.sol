pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";

import "../interfaces/IGenerativeProject.sol";

contract GenerativeNFTProxy is Proxy {
    address public immutable _generativeProjectAddr;

    // ======== Constructor =========
    constructor() public {
        _generativeProjectAddr = msg.sender;
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual override returns (address)
    {
        return IGenerativeProject(_generativeProjectAddr).getGenerativeNFTImpl();
    }
}
