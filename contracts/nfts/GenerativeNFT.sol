pragma solidity ^0.8.0;

import "./BaseERC721OwnerSeed.sol";
import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";
import "../libs/structs/NFTProject.sol";

contract GenerativeNFT is BaseERC721OwnerSeed {
    mapping(uint256 => Royalty.RoyaltyInfo) public royalties;
    NFTProject.ProjectData public _project;

    constructor (string memory name,
        string memory symbol,
        address admin) BaseERC721OwnerSeed(name, symbol) {
        _admin = admin;
    }

    function init(NFTProject.ProjectData memory project, address admin) external {
        require(_admin != address(0x0));
        require(admin != address(0x0), "INV_ADD");
        _project = project;
        _admin = admin;
        transferOwnership(_admin);
    }

    function mint(uint256 projectId) external returns (uint256 tokenId) {
        _project._index ++;
        uint256 tokenId = (_project._projectId * 1000000) + _project._index;
        _safeMint(msg.sender, tokenId);
        
        return tokenId;
    }

    /* @dev EIP2981 royalties implementation. 
    // EIP2981 standard royalties return.
    */
    function setTokenRoyalty(
        uint256 _tokenId,
        address _recipient,
        uint256 _value
    ) public {
        require(msg.sender == _admin);
        require(_value <= 10000, 'TOO_HIGH');
        royalties[_tokenId] = Royalty.RoyaltyInfo(_recipient, uint24(_value), true);
    }

    function getRoyalty(uint256 _tokenId, uint256 _salePrice) internal view virtual override
    returns (address receiver, uint256 royaltyAmount)
    {
        Royalty.RoyaltyInfo memory royalty = royalties[_tokenId];
        if (royalty.isValue) {
            receiver = royalty.recipient;
            royaltyAmount = (_salePrice * royalty.amount) / 10000;
        } else {
            (receiver, royaltyAmount) = super.getRoyalty(_tokenId, _salePrice);
        }
    }
}
