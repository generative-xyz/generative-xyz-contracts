pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "../interfaces/IParameterControl.sol";
import "../interfaces/IGenerativeProjectData.sol";
import "../interfaces/IGenerativeProject.sol";

import "../libs/helpers/Errors.sol";
import "../libs/helpers/Base64.sol";
import "../libs/helpers/StringsUtils.sol";
import "../libs/structs/NFTProject.sol";
import "../libs/structs/NFTProject.sol";
import "../libs/configs/GenerativeNFTConfigs.sol";
import "../libs/configs/GenerativeProjectDataConfigs.sol";
import "../libs/structs/NFTProjectData.sol";

contract GenerativeProjectData is OwnableUpgradeable, IGenerativeProjectData {
    address public _admin;
    address public _paramAddr;
    address public _generativeProjectAddr;

    function initialize(address admin, address paramAddr, address generativeProjectAddr) initializer public {
        _admin = admin;
        _paramAddr = paramAddr;
        _generativeProjectAddr = generativeProjectAddr;
        __Ownable_init();
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeParamAddress(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change param address
        if (_paramAddr != newAddr) {
            _admin = newAddr;
        }
    }

    function changeProjectAddress(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change Generative project address
        if (_generativeProjectAddr != newAddr) {
            _generativeProjectAddr = newAddr;
        }
    }

    /* @GenerativeProjectDATA:
    */
    function projectURI(uint256 projectId) external view returns (string memory result) {
        IGenerativeProject p = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory d = p.projectDetails(projectId);
        uint256 tokenID = projectId * GenerativeNFTConfigs.PROJECT_PADDING;
        string memory animationURI = string(abi.encodePacked(
                ', "animation_url":"data:text/html;base64,',
                Base64.encode(abi.encodePacked(this.tokenHTML(projectId, tokenID, keccak256(abi.encodePacked(tokenID))))),
                '"'
            ));
        result = string(
            abi.encodePacked('data:application/json;base64,',
            Base64.encode(abi.encodePacked(
                '{"name":"', d._name, " #", StringsUpgradeable.toString(projectId), '"',
                ',"description":"', d._desc, '"',
                ',"image":"', d._image, '"',
                animationURI,
                ',"attributes": [{"trait_type": "Collection Address", "value": "', StringsUpgradeable.toHexString(d._genNFTAddr), '"}]',
                '}'
            ))
            )
        );
    }

    /* @GenerativeTokenDATA
    */
    function tokenURI(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result) {
        NFTProjectData.TokenURIContext memory ctx;
        // get base uri
        IParameterControl param = IParameterControl(_paramAddr);
        ctx._baseURI = param.get(GenerativeProjectDataConfigs.BASE_URI_TRAIT);
        // get project info
        IGenerativeProject projectContract = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory projectDetail = projectContract.projectDetails(projectId);
        ctx._animationURI = string(abi.encodePacked(
                ', "animation_url":"data:text/html;base64,',
                Base64.encode(abi.encodePacked(this.tokenHTML(projectId, tokenId, seed))),
                '"'
            ));

        ctx._name = string(abi.encodePacked(projectDetail._name, " #", StringsUpgradeable.toString(tokenId)));
        ctx._desc = projectDetail._desc;
        if (bytes(projectDetail._itemDesc).length > 0) {
            ctx._desc = projectDetail._itemDesc;
        }

        ctx._baseURI = string(abi.encodePacked(ctx._baseURI, "/",
            StringsUpgradeable.toHexString(_generativeProjectAddr), "/",
            StringsUpgradeable.toString(tokenId), "?seed=", StringsUtils.toHex(seed)));

        result = string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(abi.encodePacked(
                    '{"name":"', ctx._name,
                    '","description": "', ctx._desc, '"',
                    ', "image": "', ctx._baseURI, '&capture=5000"',
                    ctx._animationURI,
                    ', "attributes": "', ctx._baseURI, '&capture=0"',
                    '}'
                ))
            )
        );
    }

    function tokenBaseURI(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result) {
        // get base uri
        IParameterControl param = IParameterControl(_paramAddr);
        string memory _baseURI = param.get(GenerativeProjectDataConfigs.BASE_URI);
        // get project info
        IGenerativeProject projectContract = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory projectDetail = projectContract.projectDetails(projectId);

        result = string(
            abi.encodePacked(
                _baseURI, "/",
                StringsUpgradeable.toHexString(_generativeProjectAddr), "/",
                StringsUpgradeable.toString(tokenId), "?seed=",
                StringsUtils.toHex(seed)
            )
        );
    }

    function tokenHTML(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result) {
        IGenerativeProject projectContract = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory projectDetail = projectContract.projectDetails(projectId);

        string memory scripts = "";
        for (uint256 i; i < projectDetail._scripts.length; i++) {
            scripts = string(abi.encodePacked(scripts, projectDetail._scripts[i]));
        }

        string memory scriptType = "";
        string memory randomFuncScript = '<script id="snippet-random-code" type="text/javascript">const urlSeed=new URLSearchParams(window.location.search).get("seed");urlSeed&&urlSeed.length>0&&(tokenData.seed=urlSeed);const tokenId=tokenData.tokenId,ONE_MIL=1e6,projectNumber=Math.floor(parseInt(tokenData.tokenId)/1e6),tokenMintNumber=parseInt(tokenData.tokenId)%1e6,seed=tokenData.seed;function cyrb128($){let _=1779033703,e=3144134277,t=1013904242,n=2773480762;for(let r=0,u;r<$.length;r++)_=e^Math.imul(_^(u=$.charCodeAt(r)),597399067),e=t^Math.imul(e^u,2869860233),t=n^Math.imul(t^u,951274213),n=_^Math.imul(n^u,2716044179);return _=Math.imul(t^_>>>18,597399067),e=Math.imul(n^e>>>22,2869860233),t=Math.imul(_^t>>>17,951274213),n=Math.imul(e^n>>>19,2716044179),[(_^e^t^n)>>>0,(e^_)>>>0,(t^_)>>>0,(n^_)>>>0]}function sfc32($,_,e,t){return function(){e>>>=0,t>>>=0;var n=($>>>=0)+(_>>>=0)|0;return $=_^_>>>9,_=e+(e<<3)|0,e=(e=e<<21|e>>>11)+(n=n+(t=t+1|0)|0)|0,(n>>>0)/4294967296}}let mathRand=sfc32(...cyrb128(seed));</script>';
        if (_paramAddr != address(0x0)) {
            IParameterControl param = IParameterControl(_paramAddr);
            for (uint256 i = 0; i < projectDetail._scriptType.length; i++) {
                scriptType = string(abi.encodePacked(scriptType, param.get(projectDetail._scriptType[i])));
            }
            randomFuncScript = param.get(GenerativeProjectDataConfigs.RANDOM_FUNC_SCRIPT);
        }

        result = string(abi.encodePacked(
                "<html>",
                "<head><meta charset='UTF-8'>",
                scriptType, // load lib here
                '<script type="text/javascript" id="snippet-contract-code">let tokenData = {"tokenId":', StringsUpgradeable.toString(tokenId), ', "seed": "', StringsUtils.toHex(seed), '"};</script>',
                randomFuncScript,
                '<style>', projectDetail._styles, '</style>',
                '</head><body>',
                scripts,
                "</body>",
                "</html>"
            ));
    }
}
