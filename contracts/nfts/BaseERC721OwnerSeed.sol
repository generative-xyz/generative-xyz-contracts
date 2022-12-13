pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/NFTCollection.sol";

contract BaseERC721OwnerSeed is ERC721Pausable, ReentrancyGuard, IERC2981, Ownable {
    mapping(uint256 => NFTCollection.OwnerSeed) internal _ownersAndHashSeeds;
    address public _admin;
    address public _randomizer;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
    }

    function changeAdmin(address newAdmin) external virtual {
        require(msg.sender == _admin);
        _admin = newAdmin;
    }

    function pause() external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _pause();
    }

    function unpause() external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _unpause();
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
