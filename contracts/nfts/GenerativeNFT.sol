pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./BaseERC721OwnerSeed.sol";
import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";
import "../libs/structs/NFTProject.sol";
import "../interfaces/IGenerativeProject.sol";
import "../services/Randomizer.sol";
import "../interfaces/IGenerativeNFT.sol";
import "../interfaces/IParameterControl.sol";
import "../interfaces/IGenerativeProjectData.sol";

contract GenerativeNFT is BaseERC721OwnerSeed, IGenerativeNFT {
    mapping(uint256 => Royalty.RoyaltyInfo) public royalties;
    NFTProject.ProjectData public _project;
    mapping(address => bool) _reserves;

    constructor (string memory name,
        string memory symbol,
        address admin) BaseERC721OwnerSeed(name, symbol) {
        _admin = admin;
    }

    /* @ProjectInfo: data for project data
    */
    function init(NFTProject.ProjectData memory project, address admin, address paramsAddr, address randomizer, address[] memory reserves) external {
        require(_admin != address(0x0));
        require(admin != address(0x0), "INV_ADD");
        _project = project;
        _paramsAddress = paramsAddr;
        _admin = admin;
        _randomizer = randomizer;
        for (uint256 i; i < reserves.length; i++) {
            _reserves[reserves[i]] = false;
        }
        transferOwnership(_admin);
    }

    /* @Mint
    */
    function setTokenSeed(uint256 tokenId, bytes32 seed) internal {
        require(_ownersAndHashSeeds[tokenId]._seed == bytes12(0), "Token hash already set");
        require(seed != bytes12(0), "No zero hash seed");
        _ownersAndHashSeeds[tokenId]._seed = bytes12(seed);
    }

    function paymentMintNFT() internal {
        uint256 mintPrice = _project._mintPrice;
        if (mintPrice == 0) {
            return;
        }
        address mintPriceAddr = address(0x0);
        IGenerativeProject project = IGenerativeProject(_project._projectAddr);
        IParameterControl _p = IParameterControl(_paramsAddress);
        // default 5% getting, 95% pay for owner of project
        uint256 operationFee = 500;
        if (_paramsAddress != address(0)) {
            operationFee = _p.getUInt256("MINT_NFT_OPERATOR_FEE");
        }
        if (mintPriceAddr == address(0x0)) {
            require(msg.value >= mintPrice);

            // pay for owner project
            (bool success,) = project.ownerOf(_project._projectId).call{value : mintPrice - (mintPrice * operationFee / 10000)}("");
            require(success);
            // pay for project admin
            (success,) = _admin.call{value : mintPrice * operationFee / 10000}("");
        } else {
            IERC20 tokenERC20 = IERC20(mintPriceAddr);
            // transfer all fee erc-20 token to this contract
            require(tokenERC20.transferFrom(
                    msg.sender,
                    address(this),
                    mintPrice
                ));

            // pay for owner project
            require(tokenERC20.transfer(project.ownerOf(_project._projectId), mintPrice - (mintPrice * operationFee / 10000)));
            // pay for project admin
            require(tokenERC20.transfer(_admin, mintPrice * operationFee / 10000));
        }
    }

    function mint() external returns (uint256 tokenId) {
        // safe mint
        _project._index ++;
        require(_project._index <= _project._limit);
        if (_project._index + _project._indexReserve == _project._maxSupply) {
            IGenerativeProject p = IGenerativeProject(_project._projectAddr);
            p.completeProject(_project._projectId);
        }
        tokenId = (_project._projectId * 1000000) + _project._index;
        _safeMint(msg.sender, tokenId);

        // random seed
        IRandomizer random = IRandomizer(_randomizer);
        bytes32 seed = random.generateTokenHash(tokenId);
        setTokenSeed(tokenId, seed);

        // pay
        paymentMintNFT();

        emit NFTCollection.Mint(msg.sender, tokenId);
    }

    function reserveMint() external returns (uint256 tokenId) {
        _project._indexReserve ++;
        require(_project._indexReserve + _project._limit <= _project._maxSupply);
        if (_project._index + _project._indexReserve == _project._maxSupply) {
            IGenerativeProject p = IGenerativeProject(_project._projectAddr);
            p.completeProject(_project._projectId);
        }

        IGenerativeProject p = IGenerativeProject(_project._projectAddr);
        require(!_reserves[msg.sender] || msg.sender == p.ownerOf(_project._projectId));
        tokenId = (_project._projectId * 1000000) + (_project._indexReserve + _project._limit);
        _safeMint(msg.sender, tokenId);

        // random seed
        IRandomizer random = IRandomizer(_randomizer);
        bytes32 seed = random.generateTokenHash(tokenId);
        setTokenSeed(tokenId, seed);

        emit NFTCollection.Mint(msg.sender, tokenId);
    }

    /* @TokenData:
    */

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        IGenerativeProjectData projectData = IGenerativeProjectData(_project._projectDataAddr);
        bytes32 seed = this.tokenIdToHash(tokenId);
        return projectData.tokenURI(tokenId, seed);
    }

    function tokenIdToHash(uint256 _tokenId) external view returns (bytes32) {
        if (_ownersAndHashSeeds[_tokenId]._seed == 0) {
            return 0;
        }
        return keccak256(abi.encode(_ownersAndHashSeeds[_tokenId]._seed));
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
