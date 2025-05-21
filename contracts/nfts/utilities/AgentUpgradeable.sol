// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {EIP712Upgradeable, ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {IFileStore, File} from "./IFileStore.sol";
import {RatingSystem} from "./RatingSystem.sol";
import {IEAI721AgentAbility} from "../../interfaces/IEAI721AgentAbility.sol";

abstract contract AgentUpgradeable is
    IEAI721AgentAbility,
    Initializable,
    ERC721Upgradeable,
    EIP712Upgradeable,
    RatingSystem
{
    // --- Constants ---
    uint256 public constant TOKEN_LIMIT = 10000;
    bytes32 private constant IPFS_SIG = keccak256(bytes("ipfs"));
    bytes32 private constant SIGN_DATA_TYPEHASH =
        keccak256(
            "SignData(CodePointer[] pointers,uint256[] depsAgents,uint256 agentId,uint16 currentVersion)CodePointer(address retrieveAddress,uint8 fileType,string fileName)"
        );

    // --- Storage ---
    mapping(uint256 agentId => string) private _codeLanguage; // e.g., "python", "javascript"...
    mapping(uint256 agentId => uint16) private _currentVersion;

    mapping(uint256 agentId => string) private _name;

    mapping(bytes32 digest => bool) private _usedDigests;
    mapping(uint256 agentId => mapping(uint256 version => uint256))
        private _pointersNum;
    mapping(uint256 agentId => mapping(uint256 version => mapping(uint256 => CodePointer)))
        private _codePointers;
    mapping(uint256 agentId => mapping(uint256 version => uint256[]))
        private _depsAgents;

    // --- Modifiers ---
    modifier checkVersion(uint256 agentId, uint16 version) {
        _validateVersion(agentId, version);
        _;
    }

    modifier onlyAgentOwner(uint256 agentId) {
        if (msg.sender != ownerOf(agentId)) revert Unauthenticated();
        _;
    }

    // --- Initialization ---
    function __Agent_init(
        string memory collectionName,
        string memory collectionVersion
    ) internal onlyInitializing {
        __EIP712_init(collectionName, collectionVersion);
        __RatingSystem_init();
    }

    // --- Functions ---
    function _setupAgent(
        uint256 agentId,
        string calldata name
    ) internal {
        _name[agentId] = name;
    }

    function setAgentName(
        uint256 agentId,
        string calldata name
    ) external virtual onlyAgentOwner(agentId) {
        _name[agentId] = name;
    }

    function agentName(
        uint256 agentId
    ) external view returns (string memory) {
        return _name[agentId];
    }

    function publishAgentCode(
        uint256 agentId,
        string calldata newCodeLanguage,
        CodePointer[] calldata pointers,
        uint256[] calldata newAepsAgents
    ) external virtual onlyAgentOwner(agentId) returns (uint16) {
        return _publishAgentCode(agentId, newCodeLanguage, pointers, newAepsAgents);
    }

    function publishAgentCodeWithSignature(
        uint256 agentId,
        string calldata newCodeLanguage,
        CodePointer[] calldata pointers,
        uint256[] calldata newDepsAgents,
        bytes calldata signature
    ) external virtual returns (uint16) {
        bytes32 digest = hashToSign(agentId, pointers, newDepsAgents);

        if (_usedDigests[digest]) {
            revert DigestAlreadyUsed();
        }
        if (ECDSAUpgradeable.recover(digest, signature) != ownerOf(agentId)) {
            revert Unauthenticated();
        }
        _usedDigests[digest] = true;

        return _publishAgentCode(agentId, newCodeLanguage, pointers, newDepsAgents);
    }

    function _publishAgentCode(
        uint256 agentId,
        string calldata newCodeLanguage,
        CodePointer[] calldata pointers,
        uint256[] calldata newDepsAgents
    ) internal virtual returns (uint16) {
        if (pointers.length == 0) revert InvalidData();

        _codeLanguage[agentId] = newCodeLanguage;
        uint16 version = _bumpVersion(agentId);

        uint256 pLen = pointers.length;
        for (uint256 i = 0; i < pLen; i++) {
            if (bytes(pointers[i].fileName).length == 0) {
                revert InvalidData();
            }
            _addNewCodePointer(agentId, version, pointers[i]);
        }

        uint256 depsLen = newDepsAgents.length;
        for (uint256 i = 0; i < depsLen; i++) {
            if (newDepsAgents[i] == 0 || newDepsAgents[i] > TOKEN_LIMIT) {
                revert InvalidDependency();
            }
            _depsAgents[agentId][version].push(newDepsAgents[i]);
        }

        return version;
    }

    function _bumpVersion(uint256 agentId) private returns (uint16) {
        return ++_currentVersion[agentId];
    }

    function _addNewCodePointer(
        uint256 agentId,
        uint16 version,
        CodePointer calldata pointer
    ) internal virtual {
        uint256 pNum = _getPointersNumber(agentId, version);

        _codePointers[agentId][version][pNum] = pointer;

        emit CodePointerCreated(agentId, version, pNum, pointer);
        _pointersNum[agentId][version]++;
    }

    function depsAgents(
        uint256 agentId,
        uint16 version
    ) external view checkVersion(agentId, version) returns (uint256[] memory) {
        return _depsAgents[agentId][version];
    }

    function agentCode(
        uint256 agentId,
        uint16 version
    )
        external
        view
        checkVersion(agentId, version)
        returns (string memory code)
    {
        uint256 len = _getPointersNumber(agentId, version);
        string memory libsCode = "";
        string memory mainScripts = "";

        for (uint256 pIdx = 0; pIdx < len; pIdx++) {
            CodePointer memory p = _codePointers[agentId][version][pIdx];

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
        if (keccak256(bytes(_getStorageMode(p))) == IPFS_SIG) {
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
        uint256 agentId,
        uint16 version
    ) internal view returns (uint256) {
        return _pointersNum[agentId][version];
    }

    function currentVersion(uint256 agentId) external view returns (uint16) {
        return _currentVersion[agentId];
    }

    function _validateVersion(uint256 agentId, uint16 version) internal view {
        if (version > _currentVersion[agentId]) {
            revert InvalidVersion();
        }
    }

    function codeLanguage(
        uint256 agentId
    ) external view returns (string memory) {
        return _codeLanguage[agentId];
    }

    function hashToSign(
        uint256 agentId,
        CodePointer[] calldata pointers,
        uint256[] calldata newDepsAgents
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
        bytes32 depsAgentsHash = keccak256(abi.encodePacked(newDepsAgents));

        bytes32 structHash = keccak256(
            abi.encode(
                SIGN_DATA_TYPEHASH,
                pointersHash,
                depsAgentsHash,
                agentId,
                _currentVersion[agentId]
            )
        );

        return _hashTypedDataV4(structHash);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[45] private __gap;
}
