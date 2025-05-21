// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/CryptoAIStructs.sol";
import "../interfaces/ICryptoAIData.sol";
import {IMintableAgent} from "../interfaces/IAgentNFT.sol";
import {AgentUpgradeable} from "./utilities/AgentUpgradeable.sol";
import {IEAI721Art} from "../interfaces/IEAI721Art.sol";

contract CryptoAIUpgradeable is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    IEAI721Art,
    AgentUpgradeable,
    IERC2981Upgradeable,
    OwnableUpgradeable
{
    // CryptoAIData
    address private _cryptoAiDataAddr;
    // current index mint
    uint256 private _indexMint;

    function __CryptoAI_init(
        string memory name_,
        string memory symbol_
    ) initializer public {
        __CryptoAI_init_unchained(name_, symbol_);
    }

    function __CryptoAI_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _indexMint = 1;

        __ERC721_init(name_, symbol_);
        __ERC721URIStorage_init();
        __Agent_init(name_, "1.0");
        __Ownable_init();
    }

    //@ERC721
    function mint(
        address to,
        uint256 dna,
        uint256[5] memory traits,
        string calldata agentName
    ) public virtual {
        require(to != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(_cryptoAiDataAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(_indexMint <= TOKEN_LIMIT);
        _safeMint(to, _indexMint);
        ICryptoAIData cryptoAIDataContract = ICryptoAIData(_cryptoAiDataAddr);
        cryptoAIDataContract.mintAgent(_indexMint);
        cryptoAIDataContract.unlockRenderAgent(_indexMint, dna, traits);

        _setupAgent(_indexMint, agentName);

        _indexMint += 1;
    }

    function _setCryptoAIDataAddr(address newCryptoAiDataAddr) internal virtual {
        _cryptoAiDataAddr = newCryptoAiDataAddr;
    }

    function unlock(uint256 tokenId, uint256 dna, uint256[5] memory traits) public virtual payable {
        require(_cryptoAiDataAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        ICryptoAIData cryptoAIDataContract = ICryptoAIData(_cryptoAiDataAddr);
        cryptoAIDataContract.unlockRenderAgent(tokenId, dna, traits);
    }

    function cryptoAiDataAddr() public view returns (address) {
        return _cryptoAiDataAddr;
    }

    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public virtual view override(ERC721Upgradeable, ERC721URIStorageUpgradeable, IEAI721Art) returns (string memory result) {
        require(_exists(tokenId), 'ERC721: Token does not exist');
        ICryptoAIData cryptoAIDataContract = ICryptoAIData(_cryptoAiDataAddr);
        result = cryptoAIDataContract.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(ERC721URIStorageUpgradeable).interfaceId || interfaceId == type(IERC2981Upgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /* @dev EIP2981 royalties implementation.
    // EIP2981 standard royalties return.
    */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view virtual override returns (address receiver, uint256 royaltyAmount) {
        receiver = this.owner();
        royaltyAmount = _salePrice * 0 / 10000;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[45] private __gap;
}