pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/IBaseERC721OwnerSeedUpgradeable.sol";
import "../libs/configs/GenerativeNFTConfigs.sol";
import "../libs/helpers/Errors.sol";
import "../libs/structs/NFTCollection.sol";
import "../libs/structs/Royalty.sol";
import "../interfaces/IParameterControl.sol";
import "../libs/helpers/StringsUtils.sol";

contract BaseERC721OwnerSeedUpgradeable is Initializable, ERC721PausableUpgradeable, ReentrancyGuardUpgradeable, IERC2981Upgradeable, IBaseERC721OwnerSeedUpgradeable, OwnableUpgradeable {
    mapping(uint256 => NFTCollection.OwnerSeed) internal _ownersAndHashSeeds;
    address public _admin;
    address public _paramsAddress;
    address public _randomizer;
    address public _projectDataContextAddr;
    string public _nameCol;
    uint256 public _royalty;// % royalty second sale

    function initialize(
        string memory name,
        string memory symbol
    ) initializer virtual public {
        __ERC721_init(name, symbol);
        __ReentrancyGuard_init();
        __ERC721Pausable_init();
        __Ownable_init();
    }

    function name() public view override returns (string memory) {
        return _nameCol;
    }

    function symbol() public view override returns (string memory) {
        return StringsUtils.getSlice(1, 3, _nameCol);
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        _admin = newAdm;
    }

    function changeParamAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);
        // change
        _paramsAddress = newAddr;
    }

    function changeRandomizerAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);
        // change
        _randomizer = newAddr;
    }

    function changeDataContextAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);
        // change
        _projectDataContextAddr = newAddr;
    }

    function _setStatus(bool enable) internal {
        if (enable) {
            _unpause();
        } else {
            _pause();
        }
    }

    function tokenIdToHash(uint256 tokenId) external view returns (bytes32) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        if (_ownersAndHashSeeds[tokenId]._seed == 0) {
            return 0;
        }
        return keccak256(abi.encode(_ownersAndHashSeeds[tokenId]._seed));
    }

    function getStatus() external view returns (bool) {
        return !paused();
    }

    function ownerOf(uint256 tokenId)
    public
    view
    virtual
    override
    returns (address)
    {
        return _ownersAndHashSeeds[tokenId]._owner;
    }

    function _exists(uint256 tokenId) internal view virtual override returns (bool) {
        return _ownersAndHashSeeds[tokenId]._owner != Errors.ZERO_ADDR;
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
        super._mint(to, tokenId);
        _ownersAndHashSeeds[tokenId]._owner = to;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        delete _ownersAndHashSeeds[tokenId]._owner;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._transfer(from, to, tokenId);
        _ownersAndHashSeeds[tokenId]._owner = to;
    }

    /* @dev EIP2981 royalties implementation. 
    // EIP2981 standard royalties return.
    */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view virtual override
    returns (address receiver, uint256 royaltyAmount) {
        return getRoyalty(_tokenId, _salePrice);
    }

    function getRoyalty(uint256 _tokenId, uint256 _salePrice) internal view virtual returns (address receiver, uint256 amount) {
        receiver = _admin;
        uint256 royalty = _royalty;
        if (_paramsAddress != Errors.ZERO_ADDR) {
            IParameterControl _p = IParameterControl(_paramsAddress);
            address rv = _p.getAddress(GenerativeNFTConfigs.ROYALTY_FIN_ADDRESS);
            if (rv != Errors.ZERO_ADDR) {
                receiver = rv;
            }
            if (royalty == 0) {
                royalty = _p.getUInt256(GenerativeNFTConfigs.DEFAULT_ROYALTY_FIN_PERCENT);
            }
        }

        amount = (_salePrice * royalty) / Royalty.MINT_PERCENT_ROYALTY;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, IERC165Upgradeable) returns (bool) {
        return
        interfaceId == type(IBaseERC721OwnerSeedUpgradeable).interfaceId || interfaceId == type(IERC2981Upgradeable).interfaceId ||
        super.supportsInterface(interfaceId);
    }
}
