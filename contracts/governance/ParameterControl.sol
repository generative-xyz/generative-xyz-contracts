// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IParameterControl.sol";
import "../libs/helpers/Errors.sol";

/*
 * @dev Implementation of a programmable parameter control.
 *
 * [x] Add (key, value)
 * [x] Add access control 
 *
 */

contract ParameterControl is Ownable, IParameterControl {
    event AdminChanged (address previousAdmin, address newAdmin);
    event SetEvent (string key, string value);

    // is a mutil sig address when deploy
    address public _admin;
    mapping(string => string) private _params;
    mapping(string => int) private _paramsInt;
    mapping(string => uint256) private _paramsUInt256;
    mapping(string => address) private _paramsAddress;
    mapping(string => bytes32) private _paramsBytes32;

    constructor(
        address admin
    ) {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;
    }

    modifier adminOnly() {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _;
    }

    function get(string memory key) external view returns (string memory) {
        return _params[key];
    }

    function getInt(string memory key) external view returns (int) {
        return _paramsInt[key];
    }

    function getUInt256(string memory key) external view returns (uint256) {
        return _paramsUInt256[key];
    }

    function getAddress(string memory key) external view returns (address) {
        return _paramsAddress[key];
    }

    function getBytes32(string memory key) external view returns (bytes32) {
        return _paramsBytes32[key];
    }

    function set(string memory key, string memory value) external adminOnly {
        _params[key] = value;
        emit SetEvent(key, value);
    }

    function setInt(string memory key, int value) external adminOnly {
        _paramsInt[key] = value;
    }

    function setUInt256(string memory key, uint256 value) external adminOnly {
        _paramsUInt256[key] = value;
    }

    function setAddress(string memory key, address value) external adminOnly {
        _paramsAddress[key] = value;
    }

    function setBytes32(string memory key, bytes32 value) external adminOnly {
        _paramsBytes32[key] = value;
    }

    function updateAdmin(address admin_) external adminOnly {
        require(admin_ != Errors.ZERO_ADDR && admin_ != _admin, Errors.INV_ADD);
        address previousAdmin = _admin;
        _admin = admin_;
        emit AdminChanged(previousAdmin, _admin);
    }
}
