pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../services/BFS.sol";

contract ERC721Template is ERC721, ERC721URIStorage, IERC2981, Ownable {
    Counters.Counter private _tokenIdCounter;
    address public _bfsAddr;
    uint256 public _index;

    constructor(string memory name, string memory symbol, address bfsAddr) ERC721(name, symbol) {
        _bfsAddr = bfsAddr;
    }

    function changeBFS(address newAddr) external onlyOwner {
        require(msg.sender == this.owner() && newAddr != address(0), "INV_OWNER");

        // change admin
        if (_bfsAddr != newAddr) {
            _bfsAddr = newAddr;
        }
    }

    function mintUri(address to, string memory uri) public onlyOwner {
        _index++;
        _safeMint(to, _index);
        _setTokenURI(_index, uri);

    }

    function mintChunks(address to, bytes[] memory chunks) public onlyOwner {
        _index++;
        _safeMint(to, _index);

        BFS bfs = BFS(_bfsAddr);
        for (uint256 i = 0; i < chunks.length; i++) {
            string memory fileName = Strings.toString(_index);
            bfs.store(fileName, i, chunks[i]);
        }

        _setTokenURI(_index, buildUri(_index));
    }

    function buildUri(uint256 tokenId) internal returns (string memory) {
        string memory uri = string(abi.encodePacked('bfs://',
            Strings.toString(this.getChainID()), '/',
            Strings.toHexString(_bfsAddr), "/",
            Strings.toHexString(address(this)), '/',
            Strings.toString(tokenId)));
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
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
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
