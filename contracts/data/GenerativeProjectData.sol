pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "../interfaces/IParameterControl.sol";
import "../interfaces/IGenerativeProjectData.sol";
import "../interfaces/IGenerativeProject.sol";

import "../libs/helpers/Errors.sol";
import "../libs/helpers/Base64.sol";
import "../libs/helpers/Inflate.sol";
import "../libs/helpers/StringsUtils.sol";
import "../libs/structs/NFTProject.sol";
import "../libs/structs/NFTProject.sol";
import "../libs/configs/GenerativeNFTConfigs.sol";
import "../libs/configs/GenerativeProjectDataConfigs.sol";
import "../libs/structs/NFTProjectData.sol";
import "../services/BFS.sol";

contract GenerativeProjectData is OwnableUpgradeable, IGenerativeProjectData {
    address public _admin;
    address public _paramAddr;
    address public _generativeProjectAddr;
    address public _bfs;

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
            _paramAddr = newAddr;
        }
    }

    function changeProjectAddress(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change Generative project address
        if (_generativeProjectAddr != newAddr) {
            _generativeProjectAddr = newAddr;
        }
    }

    function changeBfs(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        if (_bfs != newAddr) {
            _bfs = newAddr;
        }
    }

    /* @GenerativeProjectDATA:
    */
    function projectURI(uint256 projectId) external view returns (string memory result) {
        NFTProjectData.ProjectURIContext memory ctx;
        IGenerativeProject p = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory d = p.projectDetails(projectId);
        uint256 tokenID = projectId * GenerativeNFTConfigs.PROJECT_PADDING;
        string memory html = this.tokenHTML(projectId, tokenID, keccak256(abi.encodePacked(tokenID)));
        if (bytes(html).length > 0) {
            html = string(abi.encodePacked('data:text/html;base64,', Base64.encode(abi.encodePacked(html))));
        }
        string memory animationURI = string(abi.encodePacked(', "animation_url":"', html, '"'));

        ctx._name = string(abi.encodePacked(d._name, " #", StringsUpgradeable.toString(projectId)));
        ctx._desc = d._desc;
        string memory inflate;
        Inflate.ErrorCode err;
        (inflate, err) = inflateString(ctx._desc);
        if (err == Inflate.ErrorCode.ERR_NONE) {
            ctx._desc = inflate;
        }
        ctx._image = d._image;
        ctx._animationURI = animationURI;
        ctx._genNFTAddr = d._genNFTAddr;
        ctx._creatorAddr = d._creatorAddr;
        ctx._creator = d._creator;
        string memory scriptType = "";
        for (uint8 i; i < d._scriptType.length; i++) {
            scriptType = string(abi.encodePacked(scriptType, ',{"trait_type": "Lib ', StringsUpgradeable.toString(i + 1), '", "value": "', d._scriptType[i], '"}'));
        }
        ctx._attributes = string(abi.encodePacked(',"attributes": [{"trait_type": "Collection Address", "value": "', StringsUpgradeable.toHexString(ctx._genNFTAddr), '"}',
            ',{"trait_type": "Creator", "value": "', ctx._creator, '"}',
            ',{"trait_type": "Creator Address", "value": "', StringsUpgradeable.toHexString(ctx._creatorAddr), '"}',
            ',{"trait_type": "License", "value": "', d._license, '"}',
            scriptType,
            ']'));
        result = string(
            abi.encodePacked('data:application/json;base64,',
            Base64.encode(abi.encodePacked(
                '{"name":"', ctx._name, '"',
                ',"description":"', Base64.encode(abi.encodePacked(ctx._desc)), '"',
                ',"image":"', ctx._image, '"',
                ctx._animationURI,
                ctx._attributes,
                '}'
            ))
            )
        );
    }

    /* @GenerativeTokenDATA
    */
    function tokenURI(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result) {
        IParameterControl param = IParameterControl(_paramAddr);

        // get project info
        IGenerativeProject projectContract = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory projectDetail = projectContract.projectDetails(projectId);
        string memory html = this.tokenHTML(projectId, tokenId, seed);
        if (bytes(html).length > 0) {
            html = string(abi.encodePacked('data:text/html;base64,', Base64.encode(abi.encodePacked(html))));
            NFTProjectData.TokenURIContext memory ctx;
            ctx._animationURI = string(abi.encodePacked(', "animation_url":"', html, '"'));

            // get base uri
            ctx._baseURI = param.get(GenerativeProjectDataConfigs.BASE_URI_TRAIT);
            ctx._name = string(abi.encodePacked(projectDetail._name, " #", StringsUpgradeable.toString(tokenId)));
            ctx._desc = projectDetail._desc;
            if (bytes(projectDetail._itemDesc).length > 0) {
                ctx._desc = projectDetail._itemDesc;
            }
            string memory inflate;
            Inflate.ErrorCode err;
            (inflate, err) = inflateString(ctx._desc);
            if (err == Inflate.ErrorCode.ERR_NONE) {
                ctx._desc = inflate;
            }

            ctx._baseURI = string(abi.encodePacked(ctx._baseURI, "/",
                StringsUpgradeable.toHexString(_generativeProjectAddr), "/",
                StringsUpgradeable.toString(tokenId), "?seed=", StringsUtils.toHex(seed)));

            result = string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(abi.encodePacked(
                        '{"name":"', ctx._name,
                        '","description": "', Base64.encode(abi.encodePacked(ctx._desc)), '"',
                        ', "image": "', ctx._baseURI, '&capture=60000"',
                        ctx._animationURI,
                        ', "attributes": "', ctx._baseURI, '&capture=0"',
                        '}'
                    ))
                )
            );
        } else {
            result = string(abi.encodePacked('bfs://',
                StringsUpgradeable.toString(this.getChainID()), '/',
                StringsUpgradeable.toHexString(param.getAddress(GenerativeNFTConfigs.BFS_ADDRESS)), "/",
                StringsUpgradeable.toHexString(msg.sender), '/',
                StringsUtils.toHex(seed)));
        }
    }

    function tokenHTML(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result) {
        IGenerativeProject projectContract = IGenerativeProject(_generativeProjectAddr);
        NFTProject.Project memory projectDetail = projectContract.projectDetails(projectId);
        if (projectDetail._scripts.length == 0) {
            result = "";
        } else if (projectDetail._scripts.length == 1) {
            // for old format which used simple template file
            string memory scripts = "";
            string memory inflate;
            Inflate.ErrorCode err;
            if (bytes(projectDetail._scripts[0]).length > 0) {
                (inflate, err) = this.inflateString(projectDetail._scripts[0]);
                if (err != Inflate.ErrorCode.ERR_NONE) {
                    scripts = string(abi.encodePacked(scripts, projectDetail._scripts[0]));
                } else {
                    scripts = string(abi.encodePacked(scripts, inflate));
                }
            }
            result = scripts;
        } else {
            // for new format which used advance template file for supporting fully on-chain javascript libs
            string memory scripts = "";
            string memory inflate;
            Inflate.ErrorCode err;
            for (uint256 i = 1; i < projectDetail._scripts.length; i++) {
                if (bytes(projectDetail._scripts[i]).length > 0) {
                    (inflate, err) = this.inflateString(projectDetail._scripts[i]);
                    if (err != Inflate.ErrorCode.ERR_NONE) {
                        scripts = string(abi.encodePacked(scripts, '<script>', projectDetail._scripts[i], '</script>'));
                    } else {
                        scripts = string(abi.encodePacked(scripts, '<script>', inflate, '</script>'));
                    }
                }
            }
            scripts = string(abi.encodePacked(
                    "<html>",
                    "<head><meta charset='UTF-8'>",
                    libsScript(projectDetail._scriptType), // load libs here
                    variableScript(seed, tokenId), // load vars
                    randomFuncScript(), // load random func script
                    '<style>', projectDetail._styles, '</style>', // load css
                    '</head><body>',
                    scripts, // load main code of user
                    "</body>",
                    "</html>"
                ));
            result = scripts;
        }
    }

    function loadLibFileContent(string memory fileName) internal view returns (string memory script) {
        script = "";
        BFS bfs = BFS(_bfs);
        // count file
        address scriptProvider = IParameterControl(_paramAddr).getAddress("SCRIPT_PROVIDER");
        uint256 count = bfs.count(scriptProvider, fileName);
        count += 1;
        // load and concat string
        for (uint256 i = 0; i < count; i++) {
            (bytes memory data, int256 nextChunk) = bfs.load(scriptProvider, fileName, i);
            script = string(abi.encodePacked(script, string(data)));
        }
    }

    function libScript(string memory fileName) public view returns (string memory result){
        result = "<script sandbox='allow-scripts' type='text/javascript'>";
        result = string(abi.encodePacked(result, loadLibFileContent(fileName)));
        result = string(abi.encodePacked(result, "</script>"));
    }

    function libsScript(string[] memory libs) private view returns (string memory scriptLibs) {
        scriptLibs = "";
        for (uint256 i = 0; i < libs.length; i++) {
            string memory lib = libScript(libs[i]);
            scriptLibs = string(abi.encodePacked(scriptLibs, lib));
        }
    }

    function randomFuncScript() public view returns (string memory) {
        string memory randomFuncScript = IParameterControl(_paramAddr).get(GenerativeProjectDataConfigs.RANDOM_FUNC_SCRIPT);
        if ((bytes(randomFuncScript)).length == 0) {
            randomFuncScript = '<script id="snippet-random-code">if(null==seed){let e="0123456789abcdefghijklmnopqrstuvwsyz";seed=new URLSearchParams(window.location.search).get("seed")||Array(64).fill(0).map($=>e[Math.random()*e.length|0]).join("")+"i0"}else{let $=new URLSearchParams(window.location.search).get("seed");if($.length>0)seed=$;else{let l="seed=";for(let t=0;t<seed.length-l.length;++t)if(seed.substring(t,t+l.length)==l){seed=seed.substring(t+l.length);break}}}function cyrb128(e){let $=1779033703,l=3144134277,t=1013904242,n=2773480762;for(let _=0,i;_<e.length;_++)$=l^Math.imul($^(i=e.charCodeAt(_)),597399067),l=t^Math.imul(l^i,2869860233),t=n^Math.imul(t^i,951274213),n=$^Math.imul(n^i,2716044179);return $=Math.imul(t^$>>>18,597399067),l=Math.imul(n^l>>>22,2869860233),t=Math.imul($^t>>>17,951274213),n=Math.imul(l^n>>>19,2716044179),[($^l^t^n)>>>0,(l^$)>>>0,(t^$)>>>0,(n^$)>>>0]}function sfc32(e,$,l,t){return function(){l>>>=0,t>>>=0;var n=(e>>>=0)+($>>>=0)|0;return e=$^$>>>9,$=l+(l<<3)|0,l=(l=l<<21|l>>>11)+(n=n+(t=t+1|0)|0)|0,(n>>>0)/4294967296}}let mathRand=sfc32(...cyrb128(seed));</script>';
        }
        return randomFuncScript;
    }


    function variableScript(bytes32 seed, uint256 tokenId) public view returns (string memory result) {
        result = '<script type="text/javascript" id="snippet-contract-code">';
        result = string(abi.encodePacked(result, "let seed='", StringsUtils.toHex(seed), "';"));
        result = string(abi.encodePacked(result, "let tokenId='", StringsUpgradeable.toString(tokenId), "';"));
        result = string(abi.encodePacked(result, "</script>"));
    }

    function inflateScript(string memory script) public view returns (string memory result, Inflate.ErrorCode err) {
        return inflateString(StringsUtils.getSlice(9, bytes(script).length - 9, script));
    }

    function inflateString(string memory data) public view returns (string memory result, Inflate.ErrorCode err) {
        return inflate(Base64.decode(data));
    }

    function inflate(bytes memory data) internal view returns (string memory result, Inflate.ErrorCode err) {
        bytes memory buff;
        (err, buff) = Inflate.puff(data, data.length * 20);
        if (err == Inflate.ErrorCode.ERR_NONE) {
            uint256 breakLen = 0;
            while (true) {
                if (buff[breakLen] == 0) {
                    break;
                }
                breakLen++;
                if (breakLen == buff.length) {
                    break;
                }
            }
            bytes memory temp = new bytes(breakLen);
            uint256 i = 0;
            while (i < breakLen) {
                temp[i] = buff[i];
                i++;
            }
            result = string(temp);
        } else {
            result = "";
        }
    }

    function getChainID() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}
