pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IBaseERC721OwnerSeed.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/NFTCollection.sol";

contract BaseERC721OwnerSeed is ERC721Pausable, ReentrancyGuard, IERC2981, IBaseERC721OwnerSeed, Ownable {
    mapping(uint256 => NFTCollection.OwnerSeed) internal _ownersAndHashSeeds;
    address public _admin;
    address public _paramsAddress;
    address public _randomizer;
    address public _projectDataContextAddr;
    string public _nameCol;
    string public _symbolCol;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
    }

    function name() public view override returns (string memory) {
        return _nameCol;
    }

    function symbol() public view override returns (string memory) {
        return _symbolCol;
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            address _previousAdmin = _admin;
            _admin = newAdm;
        }
    }

    function changeParamAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_paramsAddress != newAddr) {
            _paramsAddress = newAddr;
        }
    }

    function changeRandomizerAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_randomizer != newAddr) {
            _randomizer = newAddr;
        }
    }

    function changeDataContextAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_projectDataContextAddr != newAddr) {
            _projectDataContextAddr = newAddr;
        }
    }

    function _setStatus(bool enable) internal {
        if (enable) {
            _unpause();
        } else {
            _pause();
        }
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
        return _ownersAndHashSeeds[tokenId]._owner != address(0);
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

    function getRoyalty(uint256 _tokenId, uint256 _salePrice) internal view virtual returns (address, uint256) {
        address receiver = _admin;
        uint256 amount = (_salePrice * 500) / 10000;
        return (receiver, amount);
    }
}
