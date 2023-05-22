pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "../services/BFS.sol";

contract Artifacts is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, IERC2981Upgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    address public _bfsAddr;
    address public _admin;
    uint256 public _index;

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

    function preserveUri(address to, string memory uri) public {
        _index++;
        _safeMint(to, _index);
        _setTokenURI(_index, uri);

    }

    function preserveChunks(address to, bytes[] memory chunks) public {
        _index++;
        _safeMint(to, _index);

        BFS bfs = BFS(_bfsAddr);
        for (uint256 i = 0; i < chunks.length; i++) {
            string memory fileName = StringsUpgradeable.toString(_index);
            bfs.store(fileName, i, chunks[i]);
        }

        _setTokenURI(_index, buildUri(_index));
    }

    function store(uint256 tokenId, uint256 chunkIndex, bytes memory _data) external {
        //        IParameterControl param = IParameterControl(_paramsAddress);
        //        address wl = param.getAddress(StringsUpgradeable.toHexString(msg.sender));
        // sender is wl or ownerOf
        address wl = address(0);
        require(wl != address(0) || msg.sender == ownerOf(tokenId), "INV_OWNER");
        BFS bfs = BFS(_bfsAddr);
        string memory fileName = StringsUpgradeable.toString(tokenId);
        bfs.store(fileName, chunkIndex, _data);
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

    function retrieve(uint256 tokenId) public view returns (bytes memory data, int256 nextChunk)  {
        BFS bfs = BFS(_bfsAddr);
        (data, nextChunk) = bfs.load(address(this), StringsUpgradeable.toString(tokenId), 0);
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
