pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/finance/PaymentSplitterUpgradeable.sol";

import "../interfaces/ICollaboration.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";

contract GENTokenVesting is Initializable, OwnableUpgradeable, ICollaboration, PaymentSplitterUpgradeable {
    uint256 public _releaseTime;
    address public _genToken;

    // init a payment split for [payees, shares] from 20% GENToken core-team
    // deploy 4 contract vesting and split 5% GENTOken for each
    // init release time after each year
    // and 4 year for release all GENToken
    function initialize(address[] memory payees, uint256[] memory shares, address genToken, uint256 releaseTime) initializer public {
        require(_releaseTime > block.timestamp, "INV_TIME");
        _genToken = genToken;
        _releaseTime = releaseTime;
        __PaymentSplitter_init(payees, shares);
        __Ownable_init();
    }

    /* @Release only base on time
    * not release ETH, only release GENToken
    */
    function release(address payable account) public override {
        require(block.timestamp >= _releaseTime, "INV_TIME");
        return;
    }

    function release(IERC20Upgradeable token, address account) public override {
        require(block.timestamp >= _releaseTime, "INV_TIME");
        require(address(token) == _genToken, "INV_ADDR");
        super.release(token, account);
    }
}
