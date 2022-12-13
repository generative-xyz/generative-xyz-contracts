pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "../libs/helpers/Errors.sol";
import "../libs/helpers/Base64.sol";
import "../interfaces/IParameterControl.sol";
import "../libs/structs/NFTProject.sol";
import "../interfaces/IGenerativeProjectData.sol";

contract GenerativeProjectData is OwnableUpgradeable, IGenerativeProjectData {
    address public _admin;
    address public _paramAddr;
    address public _generativeProjectAddr;

    // project traits
    mapping(uint256 => mapping(bytes => bytes[])) public _traitsAvailableValues;
    mapping(uint256 => bytes[]) public _traits;

    function initialize(address admin, address paramAddr, address generativeProjectAddr) initializer public {
        _admin = admin;
        _paramAddr = paramAddr;
        _generativeProjectAddr = generativeProjectAddr;

        __Ownable_init();
    }

    function addTrait(uint256 projectId, bytes memory name, bytes[] memory values) external {
        require(msg.sender == _admin || msg.sender == _generativeProjectAddr, Errors.INV_ADD);

        // push trait
        _traits[projectId].push(name);
        // apply available values for trait
        _traitsAvailableValues[projectId][_traits[projectId][_traits[projectId].length - 1]] = new bytes[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            _traitsAvailableValues[projectId][_traits[projectId][_traits[projectId].length - 1]][i] = values[i];
        }
    }

    function deleteTrait(uint256 projectId, uint256 index) external {
        require(msg.sender == _admin || msg.sender == _generativeProjectAddr, Errors.INV_ADD);
        // delete available values
        delete _traitsAvailableValues[projectId][_traits[projectId][index]];
        // delete trait
        delete _traits[projectId][index];
    }

    function editTrait(uint256 projectId, uint256 index, bytes memory name) external {
        require(msg.sender == _admin || msg.sender == _generativeProjectAddr, Errors.INV_ADD);
        // change name of trait
        _traits[projectId][index] = name;
    }

    function addTraitValue(uint256 projectId, uint256 indexTrait, bytes memory value) external {
        require(msg.sender == _admin || msg.sender == _generativeProjectAddr, Errors.INV_ADD);
        // push a new available value for trait
        _traitsAvailableValues[projectId][_traits[projectId][indexTrait]].push(value);
    }

    function deleteTraitValue(uint256 projectId, uint256 indexTrait, uint256 indexValue) external {
        require(msg.sender == _admin || msg.sender == _generativeProjectAddr, Errors.INV_ADD);
        // delete an available value for trait
        delete _traitsAvailableValues[projectId][_traits[projectId][indexTrait]][indexValue];
    }

    function getTraits(uint256 projectId) external view returns (bytes[] memory traitsName) {
        return _traits[projectId];
    }

    function getTraitsAvailableValues(uint256 projectId) external view returns (bytes[][] memory) {
        bytes[][] memory result = new bytes[][](_traits[projectId].length);
        for (uint256 i = 0; i < _traits[projectId].length; i++) {
            result[i] = _traitsAvailableValues[projectId][_traits[projectId][i]];
        }
        return result;
    }

    function tokenURI(uint256 projectId, bytes32 seed) external view returns (string memory result) {
        // TODO with seed
        NFTProject.ProjectURIContext memory ctx;
        ctx.animationURI = string(abi.encodePacked(
                ', "animation_url":"data:text/html;charset=utf-8,',
                this.tokenHTML(projectId, seed),
                '"'
            ));
        result = string(
            abi.encodePacked('data:application/json;base64,',
            Base64.encode(abi.encodePacked(
                '{"name":"', ctx.name,
                '","description":"Powers by generative.xyz"',
                ctx.animationURI,
                tokenTraits(projectId, seed),
                '}'
            ))
            )
        );
    }

    function tokenHTML(uint256 projectId, bytes32 seed) external view returns (string memory result) {
        // TODO with seed
        IParameterControl param = IParameterControl(_paramAddr);
        result = string(abi.encodePacked("<html><head><meta charset='UTF-8'><style>html,body,svg{margin:0;padding:0; height:100%;text-align:center;}</style>",
            param.get("three.js"), // load threejs lib here
            "<script>let seed = ", string(abi.encodePacked(seed)), ";</script></head><body>",
            "<div id='container-el'></div>",
            "<script>//TODO running script</script>",
            "</body></html>"
            ));
    }

    function tokenTraits(uint256 projectId, bytes32 seed) internal view returns (string memory result) {
        // TODO with seed
        string memory traits = "";
        for (uint256 i = 0; i < _traits[projectId].length; i++) {
            traits = string(abi.encodePacked(traits, '{"trait_type":"', _traits[projectId][i], '","value":"', _traits[projectId][i][0], '"}'));
            if (i < _traits[projectId].length - 1) {
                traits = string(abi.encodePacked(traits, ','));
            }
        }
        result = string(abi.encodePacked('"attributes":[', traits, ']'));
    }
}
