// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {EIP712Upgradeable, ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {IAgent} from "./IAgent.sol";
import {IFileStore, File} from "./IFileStore.sol";

abstract contract AgentUpgradeable is
    IAgent,
    Initializable,
    ERC721Upgradeable,
    EIP712Upgradeable
{
    bytes32 private constant _IPFS_SIG = keccak256(bytes("ipfs"));
    bytes32 private constant SIGN_DATA_TYPEHASH =
        keccak256(
            "SignData(CodePointer[] pointers,address[] depsAgents,uint256 tokenId,uint16 currentVersion)CodePointer(address retrieveAddress,uint8 fileType,string fileName)"
        );

    mapping(uint256 tokenId => string) private _codeLanguage; // e.g., "python", "javascript"...
    mapping(uint256 tokenId => uint16) private _currentVersion;

    mapping(uint256 tokenId => string) private _personality;
    mapping(uint256 tokenId => string) private _ability;

    mapping(bytes32 digest => bool) private _usedDigests;
    mapping(uint256 tokenId => mapping(uint256 version => uint256))
        private _pointersNum;
    mapping(uint256 tokenId => mapping(uint256 version => mapping(uint256 => CodePointer)))
        private _codePointers;
    mapping(uint256 tokenId => mapping(uint256 version => address[]))
        private _depsAgents;

    uint256[30] private __gap;

    modifier checkVersion(uint256 tokenId, uint16 version) {
        _validateVersion(tokenId, version);
        _;
    }

    modifier onlyAgentOwner(uint256 tokenId) {
        if (msg.sender != ownerOf(tokenId)) revert Unauthenticated();
        _;
    }

    function __Agent_init(
        string memory collectionName,
        string memory collectionVersion
    ) internal onlyInitializing {
        __EIP712_init(collectionName, collectionVersion);
    }

    function _setupAgent(
        uint256 tokenId,
        string memory codeLanguage,
        string memory personality,
        string memory ability,
        CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) internal {
        _codeLanguage[tokenId] = codeLanguage;
        _personality[tokenId] = personality;
        _ability[tokenId] = ability;
        _publishAgentCode(tokenId, pointers, depsAgents);
    }

    function updateAgentPersonality(
        uint256 tokenId,
        string calldata personality
    ) external virtual onlyAgentOwner(tokenId) {
        _personality[tokenId] = personality;
    }

    function getAgentPersonality(
        uint256 tokenId
    ) external view returns (string memory) {
        return _personality[tokenId];
    }

    function updateAgentAbility(
        uint256 tokenId,
        string calldata ability
    ) external virtual onlyAgentOwner(tokenId) {
        _ability[tokenId] = ability;
    }

    function getAgentAbility(
        uint256 tokenId
    ) external view returns (string memory) {
        return _ability[tokenId];
    }

    function publishAgentCode(
        uint256 tokenId,
        CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) external virtual onlyAgentOwner(tokenId) returns (uint16) {
        return _publishAgentCode(tokenId, pointers, depsAgents);
    }

    function publishAgentCodeWithSignature(
        uint256 tokenId,
        CodePointer[] calldata pointers,
        address[] calldata depsAgents,
        bytes calldata signature
    ) external virtual returns (uint16) {
        bytes32 digest = getHashToSign(tokenId, pointers, depsAgents);
        if (_usedDigests[digest]) {
            revert DigestAlreadyUsed();
        }
        if (ECDSAUpgradeable.recover(digest, signature) != ownerOf(tokenId)) {
            revert Unauthenticated();
        }

        _usedDigests[digest] = true;

        return _publishAgentCode(tokenId, pointers, depsAgents);
    }

    function _publishAgentCode(
        uint256 tokenId,
        CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) internal virtual returns (uint16) {
        // if (pointers.length == 0) revert InvalidData();

        uint16 version = _bumpVersion(tokenId);

        uint256 pLen = pointers.length;
        for (uint256 i = 0; i < pLen; i++) {
            if (bytes(pointers[i].fileName).length == 0) {
                revert InvalidData();
            }
            _addNewCodePointer(tokenId, version, pointers[i]);
        }

        uint256 depsLen = depsAgents.length;
        for (uint256 i = 0; i < depsLen; i++) {
            if (depsAgents[i] == address(0)) {
                revert ZeroAddress();
            }
            _depsAgents[tokenId][version].push(depsAgents[i]);
        }

        return version;
    }

    function _bumpVersion(uint256 tokenId) private returns (uint16) {
        return ++_currentVersion[tokenId];
    }

    function _addNewCodePointer(
        uint256 tokenId,
        uint16 version,
        CodePointer calldata pointer
    ) internal virtual {
        uint256 pNum = _getPointersNumber(tokenId, version);

        _codePointers[tokenId][version][pNum] = pointer;

        emit CodePointerCreated(version, pNum, pointer);
        _pointersNum[tokenId][version]++;
    }

    function getDepsAgents(
        uint256 tokenId,
        uint16 version
    ) external view checkVersion(tokenId, version) returns (address[] memory) {
        return _depsAgents[tokenId][version];
    }

    function getAgentCode(
        uint256 tokenId,
        uint16 version
    )
        external
        view
        checkVersion(tokenId, version)
        returns (string memory code)
    {
        uint256 len = _getPointersNumber(tokenId, version);
        string memory libsCode = "";
        string memory mainScripts = "";

        for (uint256 pIdx = 0; pIdx < len; pIdx++) {
            CodePointer memory p = _codePointers[tokenId][version][pIdx];

            string memory codeChunk = _getCodeByPointer(p);

            if (p.fileType == FileType.LIBRARY) {
                libsCode = _concatStrings(libsCode, codeChunk);
            } else if (p.fileType == FileType.MAIN_SCRIPT) {
                mainScripts = _concatStrings(mainScripts, codeChunk);
            }
        }

        if (bytes(libsCode).length == 0 && bytes(mainScripts).length == 0)
            return "";

        return _concatStrings(libsCode, mainScripts);
    }

    function _concatStrings(
        string memory a,
        string memory b
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(a, "\n", b));
    }

    function _getCodeByPointer(
        CodePointer memory p
    ) internal view virtual returns (string memory logic) {
        if (keccak256(bytes(_getStorageMode(p))) == _IPFS_SIG) {
            logic = p.fileName; // return the IPFS hash
        } else {
            logic = IFileStore(p.retrieveAddress).getFile(p.fileName).read();
        }
    }

    function _getStorageMode(
        CodePointer memory p
    ) internal view virtual returns (string memory) {
        if (p.retrieveAddress != address(0)) {
            return "fs";
        }
        return "ipfs";
    }

    function _getPointersNumber(
        uint256 tokenId,
        uint16 version
    ) internal view returns (uint256) {
        return _pointersNum[tokenId][version];
    }

    function getCurrentVersion(uint256 tokenId) external view returns (uint16) {
        return _currentVersion[tokenId];
    }

    function _validateVersion(uint256 tokenId, uint16 version) internal view {
        if (version > _currentVersion[tokenId]) {
            revert InvalidVersion();
        }
    }

    function getCodeLanguage(
        uint256 tokenId
    ) external view returns (string memory) {
        return _codeLanguage[tokenId];
    }

    function getHashToSign(
        uint256 tokenId,
        CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) public view virtual returns (bytes32) {
        bytes32 CODEPOINTER_TYPEHASH = keccak256(
            "CodePointer(address retrieveAddress,uint8 fileType,string fileName)"
        );

        bytes32[] memory pointerHashes = new bytes32[](pointers.length);

        uint256 pLen = pointers.length;
        for (uint i = 0; i < pLen; i++) {
            pointerHashes[i] = keccak256(
                abi.encode(
                    CODEPOINTER_TYPEHASH,
                    pointers[i].retrieveAddress,
                    pointers[i].fileType,
                    keccak256(bytes(pointers[i].fileName))
                )
            );
        }

        bytes32 pointersHash = keccak256(abi.encodePacked(pointerHashes));
        bytes32 depsAgentsHash = keccak256(abi.encodePacked(depsAgents));

        bytes32 structHash = keccak256(
            abi.encode(
                SIGN_DATA_TYPEHASH,
                pointersHash,
                depsAgentsHash,
                tokenId,
                _currentVersion[tokenId]
            )
        );

        return _hashTypedDataV4(structHash);
    }
}
