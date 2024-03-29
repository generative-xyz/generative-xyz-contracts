pragma solidity ^0.8.0;

/*import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

import "../libs/helpers/Base64.sol";
import "../libs/helpers/Errors.sol";
import "./MultiSigWallet/MultiSigWalletFactory.sol";
import "./BFS.sol";

contract TrustlessPhotos is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, OwnableUpgradeable {
    address public _admin;
    address public _parameterAddr;
    address public _bfsAddr;
    uint256 public _index;
    mapping(address => uint256[]) public ownedPhotos;
    mapping(address => mapping(string => uint256[])) public albumPhotos;
    mapping(address => string[]) public ownedAlbums;

    function initialize(address admin, address parameterControl, address bfsAddr) initializer virtual public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;
        _parameterAddr = parameterControl;
        _bfsAddr = bfsAddr;
        __Ownable_init();
        __ERC721_init("", "");
        __ERC721URIStorage_init();
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeParam(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        if (_parameterAddr != newAddr) {
            _parameterAddr = newAddr;
        }
    }

    function changeBFS(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        if (_bfsAddr != newAddr) {
            _bfsAddr = newAddr;
        }
    }

    // @NOTE:upload
    function upload(bytes[][] memory photos, string memory album) public {
        for (uint256 f = 0; f < photos.length; f++) {
            _index++;
            bytes32 tokenHash = keccak256(
                abi.encodePacked(
                    _index,
                    block.number,
                    blockhash(block.number - 1),
                    block.timestamp
                )
            );
            uint256 photoIndex = uint256(tokenHash) & 0xfff;
            // mint
            _safeMint(msg.sender, photoIndex);
            // store bfs
            BFS bfs = BFS(_bfsAddr);
            string memory fileName = buildFileName(msg.sender, photoIndex);
            for (uint256 i = 0; i < photos[f].length; i++) {
                bfs.store(fileName, i, photos[f][i]);
            }
            // set uri
            _setTokenURI(photoIndex, buildUri(fileName));
            ownedPhotos[msg.sender].push(photoIndex);
            if (albumPhotos[msg.sender][album].length == 0) {
                ownedAlbums[msg.sender].push(album);
            }
            albumPhotos[msg.sender][album].push(photoIndex);
        }
    }

    // @NOTE:getting
    function linkPhoto(uint256 photoIndex) public view returns (string memory) {
        if (msg.sender == ownerOf(photoIndex)) {
            return buildUri(buildFileName(msg.sender, photoIndex));
        } else {
            return "";
        }
    }

    function listPhotos() public view returns (uint256[] memory) {
        return ownedPhotos[msg.sender];
    }

    function listAlbums() public view returns (string[] memory) {
        return ownedAlbums[msg.sender];
    }

    function listAlbumPhotos(string memory album) public view returns (uint256[] memory) {
        return albumPhotos[msg.sender][album];
    }

    function countPhotos() public view returns (uint256) {
        return ownedPhotos[msg.sender].length;
    }

    function countAlbums() public view returns (uint256) {
        return ownedAlbums[msg.sender].length;
    }

    function countAlbumPhotos(string memory album) public view returns (uint256) {
        return albumPhotos[msg.sender][album].length;
    }

    // @NOTE:download
    function downloadPartial(uint256 photoIndex, uint256 chunkIndex) public view returns (bytes memory data, int256 nextChunk)  {
        if (msg.sender != ownerOf(photoIndex)) {
            return (data, - 1);
        }
        BFS bfs = BFS(_bfsAddr);
        string memory fileName = buildFileName(msg.sender, photoIndex);
        (data, nextChunk) = bfs.load(address(this), fileName, chunkIndex);
    }

    function download(uint256 photoIndex) public view returns (bytes[] memory data) {
        if (msg.sender != ownerOf(photoIndex)) {
            return data;
        }
        BFS bfs = BFS(_bfsAddr);
        string memory fileName = buildFileName(msg.sender, photoIndex);
        uint256 count = bfs.count(address(this), fileName);
        count += 1;
        bytes[] memory result = new bytes[](count);
        for (uint256 i = 0; i < count; i++) {
            (bytes memory data, int256 nextChunk) = bfs.load(address(this), fileName, i);
            result[i] = data;
        }
        return result;
    }

    // @NOTE:helpers
    // helper functions
    function buildFileName(address owner, uint256 tokenId) internal view returns (string memory){
        return string(abi.encodePacked(
                StringsUpgradeable.toHexString(owner),
                "/",
                StringsUpgradeable.toString(tokenId))
        );
    }

    function buildUri(string memory fileName) internal view returns (string memory) {
        string memory uri = string(abi.encodePacked('bfs://',
            StringsUpgradeable.toString(this.getChainID()), '/',
            StringsUpgradeable.toHexString(_bfsAddr), "/",
            StringsUpgradeable.toHexString(address(this)), '/',
            fileName
            )
        );
        return uri;
    }

    function getChainID() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }


    // @NOTE:override
    //The following functions are overrides required by Solidity.
    function approve(address to, uint256 tokenId) public override {}

    function setApprovalForAll(address operator, bool approved) public override {}

    function getApproved(uint256 tokenId) public view override returns (address){
        return address(0);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return false;
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        return;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        return;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        return;
    }

    function _burn(uint256 tokenId) internal override(IERC721UpgradeableERC721Upgradeable, ERC721URIStorageUpgradeable) {
        return;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory){
        if (msg.sender == ownerOf(tokenId)) {
            return super.tokenURI(tokenId);
        } else {
            return "";
        }
    }
}*/
