pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

import "../interfaces/ICollaboration.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";

contract CollaborationCreator is Ownable, ICollaboration, IERC721Receiver, PaymentSplitter {
    constructor(address[] memory payees, uint256[] memory shares_) PaymentSplitter(payees, shares_) {}

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return
        bytes4(
            keccak256("onERC721Received(address,address,uint256,bytes)")
        );
    }
}
