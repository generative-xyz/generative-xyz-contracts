pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import '@openzeppelin/contracts/utils/Base64.sol';

import "../libs/helpers/Errors.sol";
import "../libs/structs/CryptoAIStructs.sol";
import "../interfaces/ICryptoAIData.sol";

import 'hardhat/console.sol';
import {IMintableAgent} from "../interfaces/IAgentNFT.sol";

contract CryptoAI is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, IERC2981Upgradeable, OwnableUpgradeable {
    uint256 public constant TOKEN_LIMIT = 10000;
    uint256 public constant MINT_PRINT = 1 ** 18;

    // deployer
    address public _deployer;
    // CryptoAIData
    address public _cryptoAiDataAddr;
    // admins
    mapping(address => bool) _admins;

    uint256 public _indexMint;

    mapping(uint256 => address) public _agentAddresses;

    modifier onlyDeployer() {
        require(msg.sender == _deployer, Errors.ONLY_DEPLOYER);
        _;
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender], Errors.ONLY_DEPLOYER);
        _;
    }

    function initialize(
        string memory name,
        string memory symbol,
        address deployer
    ) initializer public {
        _deployer = deployer;
        _indexMint = 1;

        __ERC721_init(name, symbol);
        __ERC721URIStorage_init();
        __Ownable_init();
    }

    function changeDeployer(address newAdm) external onlyDeployer {
        require(newAdm != Errors.ZERO_ADDR, Errors.INV_ADD);
        if (_deployer != newAdm) {
            _deployer = newAdm;
        }
    }

    function allowAdmin(address newAdm, bool allow) external onlyDeployer {
        require(newAdm != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admins[newAdm] = allow;
    }

    function changeCryptoAiDataAddress(address newAddr) external onlyDeployer {
        require(newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        if (_cryptoAiDataAddr != newAddr) {
            _cryptoAiDataAddr = newAddr;
        }
    }

    //@ERC721
    function mint(address to, address agentAddress, uint256 dna, uint256[5] memory traits) public onlyAdmin {
        require(to != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(agentAddress != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(_cryptoAiDataAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(_indexMint <= TOKEN_LIMIT);
        _safeMint(to, _indexMint);
        _agentAddresses[_indexMint] = agentAddress;
        ICryptoAIData cryptoAIDataContract = ICryptoAIData(_cryptoAiDataAddr);
        cryptoAIDataContract.mintAgent(_indexMint);
        unlock(_indexMint, dna, traits);

        _indexMint += 1;
    }

    function unlock(uint256 tokenId, uint256 dna, uint256[5] memory traits) public payable {
        require(_cryptoAiDataAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        ICryptoAIData cryptoAIDataContract = ICryptoAIData(_cryptoAiDataAddr);
        cryptoAIDataContract.unlockRenderAgent(tokenId, dna, traits);
    }

    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory result) {
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
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view virtual override
    returns (address receiver, uint256 royaltyAmount) {
        receiver = this.owner();
        royaltyAmount = _salePrice * 0 / 10000;
    }
}