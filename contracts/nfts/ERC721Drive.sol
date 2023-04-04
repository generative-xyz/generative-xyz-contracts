pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "../services/BFS.sol";

contract ERC721Drive is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, IERC2981Upgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;
    address public _bfsAddr;
    address public _admin;

    function initialize(
        string memory name,
        string memory symbol,
        address bfsAddr
    ) initializer public {
        _admin = msg.sender;
        _bfsAddr = bfsAddr;
        __ERC721_init(name, symbol);
        __ERC721URIStorage_init();
        __Ownable_init();
    }


    function changeBFS(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), "INV_OWNER");

        // change admin
        if (_bfsAddr != newAddr) {
            _bfsAddr = newAddr;
        }
    }

    function changeAdmin(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), "INV_OWNER");

        // change admin
        if (_admin != newAddr) {
            _admin = newAddr;
        }
    }

    function mintUri(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

    }

    function mintChunk(address to, bytes memory chunks) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        BFS bfs = BFS(_bfsAddr);
        string memory fileName = StringsUpgradeable.toString(tokenId);
        bfs.store(fileName, 0, chunks);

        _setTokenURI(tokenId, buildUri(tokenId));
    }

    function mintChunks(address to, bytes[] memory chunks) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        BFS bfs = BFS(_bfsAddr);
        for (uint256 i = 0; i < chunks.length; i++) {
            string memory fileName = StringsUpgradeable.toString(tokenId);
            bfs.store(fileName, i, chunks[i]);
        }

        _setTokenURI(tokenId, buildUri(tokenId));
    }

    function buildUri(uint256 tokenId) internal returns (string memory) {
        string memory uri = string(abi.encodePacked('bfs://',
            StringsUpgradeable.toString(this.getChainID()), '/',
            StringsUpgradeable.toHexString(_bfsAddr), "/",
            StringsUpgradeable.toHexString(address(this)), '/',
            StringsUpgradeable.toString(tokenId)));
        return uri;
    }

    function getChainID() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /* @dev EIP2981 royalties implementation. 
    // EIP2981 standard royalties return.
    */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view virtual override
    returns (address receiver, uint256 royaltyAmount) {
        receiver = this.owner();
        royaltyAmount = _salePrice * 1000 / 10000;
    }
}
