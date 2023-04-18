pragma solidity ^0.8.0;

import "./MultiSigWallet.sol";

contract MultiSigWalletFactory {
    event ContractInstantiation(address sender, address instantiation);

    mapping(address => bool) public isInstantiation;
    mapping(address => address[]) public instantiations;

    function create(address[] memory _owners, uint _required) public returns (address wallet)
    {
        MultiSigWallet walletContract = new MultiSigWallet(_owners, _required);
        wallet = address(walletContract);
        register(wallet);
    }

    function getInstantiationCount(address creator) public returns (uint) {
        return instantiations[creator].length;
    }

    function register(address wallet) internal {
        isInstantiation[wallet] = true;
        instantiations[msg.sender].push(wallet);
        emit ContractInstantiation(msg.sender, wallet);
    }
}
