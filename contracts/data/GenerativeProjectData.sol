pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "../libs/helpers/Errors.sol";
import "../libs/helpers/Base64.sol";
import "../interfaces/IParameterControl.sol";
import "../libs/structs/NFTProject.sol";
import "../interfaces/IGenerativeProjectData.sol";
import "../interfaces/IGenerativeProject.sol";
import "../libs/structs/NFTProject.sol";

contract GenerativeProjectData is OwnableUpgradeable, IGenerativeProjectData {
    address public _admin;
    address public _paramAddr;
    address public _generativeProjectAddr;
    string public _baseURI;

    // project traits
    mapping(uint256 => mapping(bytes => bytes[])) public _traitsAvailableValues;
    mapping(uint256 => bytes[]) public _traits;

    function initialize(address admin, address paramAddr, address generativeProjectAddr, string memory baseUri) initializer public {
        _admin = admin;
        _paramAddr = paramAddr;
        _generativeProjectAddr = generativeProjectAddr;
        _baseURI = baseUri;
        __Ownable_init();
    }

    /* @ProjectTraits
    */
    function initTrait(uint256 projectId, bytes[] memory traits, bytes[][] memory listValues) external {
        require(msg.sender == _admin || msg.sender == _generativeProjectAddr, Errors.INV_ADD);
        for (uint256 i = 0; i < traits.length; i++) {
            bytes memory name = traits[i];
            bytes[] memory values = listValues[i];
            // push trait
            _traits[projectId].push(name);
            // apply available values for trait
            _traitsAvailableValues[projectId][_traits[projectId][_traits[projectId].length - 1]] = new bytes[](values.length);
            for (uint256 i = 0; i < values.length; i++) {
                _traitsAvailableValues[projectId][_traits[projectId][_traits[projectId].length - 1]][i] = values[i];
            }
        }

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

    /* @GenerativeProjectDATA:
    */
    function projectURI(uint256 projectId) external view returns (string memory result) {
        IGenerativeProject p = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory d = p.projectDetails(projectId);
        string memory animationURI = string(abi.encodePacked(
                ', "animation_url":"data:text/html;charset=utf-8,',
                this.tokenHTML(projectId, 0, keccak256(abi.encodePacked(uint256(0)))),
                '"'
            ));
        result = string(
            abi.encodePacked('data:application/json;base64,',
            Base64.encode(abi.encodePacked(
                '{"name":"', d._name,
                '","description":"', d._desc, '"',
                '","image":"', d._image, '"',
                animationURI,
                '}'
            ))
            )
        );
    }

    /* @GenerativeTokenDATA
    */
    function tokenURI(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result) {
        IGenerativeProject projectContract = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory projectDetail = projectContract.projectDetails(projectId);
        string memory animationURI = string(abi.encodePacked(
                ', "animation_url":"data:text/html;charset=utf-8,',
                this.tokenHTML(projectId, tokenId, seed),
                '"'
            ));
        result = string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(abi.encodePacked(
                    '{"name":"', projectDetail._name,
                    '","description":"Powers by generative.xyz"',
                    animationURI,
                    tokenTraits(projectId, seed),
                    '}'
                ))
            )
        );
    }

    function tokenBaseURI(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result) {
        IGenerativeProject projectContract = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory projectDetail = projectContract.projectDetails(projectId);

        result = string(
            abi.encodePacked(
                _baseURI, "/",
                StringsUpgradeable.toString(tokenId), "/",
                string(abi.encodePacked(seed))
            )
        );
    }

    function tokenHTML(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result) {
        IGenerativeProject projectContract = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory projectDetail = projectContract.projectDetails(projectId);

        IParameterControl param = IParameterControl(_paramAddr);
        string memory scripts = "";
        for (uint256 i; i < projectDetail._scripts.length; i++) {
            scripts = string(abi.encodePacked(scripts, '<script type="text/javascript">', projectDetail._scripts[i], '</script>'));
        }
        result = string(abi.encodePacked(
                "<html>",
                "<head><meta charset='UTF-8'>",
                param.getBytes32(projectDetail._scriptType), // load lib here
                '<script type="text/javascript">let tokenData = {"tokenId":', StringsUpgradeable.toString(tokenId), ', "seed": "', string(abi.encodePacked(seed)), '"};</script>',
                '<script type="text/javascript">const tokenId=tokenData.tokenId,ONE_MIL=1e6,projectNumber=Math.floor(parseInt(tokenData.tokenId)/1e6),tokenMintNumber=parseInt(tokenData.tokenId)%1e6,seed=tokenData.seed;function cyrb128($){let _=1779033703,e=3144134277,t=1013904242,n=2773480762;for(let r=0,u;r<$.length;r++)_=e^Math.imul(_^(u=$.charCodeAt(r)),597399067),e=t^Math.imul(e^u,2869860233),t=n^Math.imul(t^u,951274213),n=_^Math.imul(n^u,2716044179);return _=Math.imul(t^_>>>18,597399067),e=Math.imul(n^e>>>22,2869860233),t=Math.imul(_^t>>>17,951274213),n=Math.imul(e^n>>>19,2716044179),[(_^e^t^n)>>>0,(e^_)>>>0,(t^_)>>>0,(n^_)>>>0]}function sfc32($,_,e,t){return function(){e>>>=0,t>>>=0;var n=($>>>=0)+(_>>>=0)|0;return $=_^_>>>9,_=e+(e<<3)|0,e=(e=e<<21|e>>>11)+(n=n+(t=t+1|0)|0)|0,(n>>>0)/4294967296}}let mathRand=sfc32(...cyrb128(seed));</script>',
                scripts,
                '<style>', projectDetail._styles, '</style>',
                '</head><body>',
                "<div id='container-el'></div>",
                "</body>",
                "</html>"
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
