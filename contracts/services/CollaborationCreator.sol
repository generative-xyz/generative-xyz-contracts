pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/ICollaboration.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";

contract CollaborationCreator is Ownable, ReentrancyGuard, ICollaboration, IERC721Receiver {
    mapping(address => uint256) public _collaborations;
    address[] public _collaborators;
    uint256 public _total;

    constructor(Royalty.CollaborationShared memory params) {
        for (uint256 i; i < params._collaborators.length; i++) {
            _collaborations[params._collaborators[i]] = params._shared[i];
            _collaborators.push(params._collaborators[i]);
            _total += params._shared[i];
        }
    }

    function calculateShared() internal view returns (uint256[] memory) {
        uint256[] memory result;
        uint256 a = 0;
        for (uint256 i = 0; i < _collaborators.length - 1; i++) {
            result[i] = _collaborations[_collaborators[i]] / _total * 10000;
            a += result[i];
        }

        result[_collaborators.length - 1] = 10000 - a;
        return result;
    }

    function withdraw(address erc20Addr) external nonReentrant {
        require(_collaborations[msg.sender] > 0, Errors.ONLY_ADMIN_ALLOWED);
        bool success;
        // calculate %
        uint256[] memory cal = calculateShared();
        uint256 balance = 0;
        if (erc20Addr == address(0x0)) {
            balance = address(this).balance;
            for (uint256 i = 0; i < cal.length; i++) {
                (success,) = _collaborators[i].call{value : balance * cal[i] / 10000}("");
                require(success);
            }
        } else {
            IERC20 tokenERC20 = IERC20(erc20Addr);
            balance = tokenERC20.balanceOf(address(this));
            // transfer erc-20 token
            for (uint256 i = 0; i < cal.length; i++) {
                require(tokenERC20.transfer(_collaborators[i], balance * cal[i] / 10000));
            }
        }
    }

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
