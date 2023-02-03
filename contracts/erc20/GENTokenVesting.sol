pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/finance/PaymentSplitterUpgradeable.sol";

import "../interfaces/ICollaboration.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";

contract GENTokenVesting is Initializable, OwnableUpgradeable, ICollaboration, PaymentSplitterUpgradeable {
    address public _genToken;
    address public _admin;

    // init a payment split for [payees, shares] from 30% GENToken core-team
    function initialize(address admin, address[] memory payees, uint256[] memory shares, address genToken) initializer public {
        _genToken = genToken;
        __PaymentSplitter_init(payees, shares);
        __Ownable_init();
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeGENToken(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.INV_ADD);

        // change admin
        if (_genToken != newAddr) {
            _genToken = newAddr;
        }
    }

    /* @Release only base on time
    * not release ETH, only release GENToken
    */
    function release(address payable account) public override {
        return;
    }

    function release(IERC20Upgradeable token, address account) public override {
        require(address(token) == _genToken, "INV_ADDR");
        super.release(token, account);
    }
}