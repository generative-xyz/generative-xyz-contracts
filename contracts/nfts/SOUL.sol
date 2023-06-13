pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";
import "../libs/structs/NFTCollection.sol";
import "../libs/structs/NFTProjectData.sol";
import "../interfaces/IParameterControl.sol";
import "../libs/helpers/Base64.sol";
import "../libs/helpers/StringsUtils.sol";
import "../libs/configs/GenerativeProjectDataConfigs.sol";
import "../interfaces/IRandomizer.sol";
import "../services/BFS.sol";
import "../interfaces/IAuction.sol";
import "../libs/structs/Auction.sol";

contract SOUL is Initializable, ERC721PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, IERC2981Upgradeable, IAuction {

    event Reserve(address indexed reserver, uint256 indexed tokenId, address indexed owner, uint256 blockNumber);
    event Claim(address indexed reserver, uint256 indexed tokenId, address indexed owner, uint256 blockNumber);

    address public _admin;
    address public _paramsAddress;
    address public _randomizerAddr;
    uint256 private _currentId;
    string public _script;
    address public _gmToken;
    uint256 public _maxSupply;

    mapping(uint256 => NFTCollection.OwnerSeed) internal _ownersAndHashSeeds;
    mapping(uint256 => uint256) public _mintAt;

    address public _bfs;

    mapping(uint256 => AuctionHouse.Auction) public _auctions;
    mapping(uint256 => mapping(address => uint256)) public _bidders;

    address public _signerMint;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramsAddress,
        address randomizerAddr,
        address gmToken,
        address bfs
    ) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(paramsAddress != Errors.ZERO_ADDR, Errors.INV_ADD);
        _paramsAddress = paramsAddress;
        _admin = admin;
        _randomizerAddr = randomizerAddr;
        _gmToken = gmToken;
        _maxSupply = 1000;
        _bfs = bfs;

        __ERC721_init(name, symbol);
        __ReentrancyGuard_init();
        __ERC721Pausable_init();
        __Ownable_init();
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeSignerMint(address newAdd) external {
        require(msg.sender == _admin && newAdd != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        if (_signerMint != newAdd) {
            _signerMint = newAdd;
        }
    }

    function changeParamAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_paramsAddress != newAddr) {
            _paramsAddress = newAddr;
        }
    }

    function changeRandomizerAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_randomizerAddr != newAddr) {
            _randomizerAddr = newAddr;
        }
    }

    function changeScript(string memory newScript) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _script = newScript;
    }

    function changeBrc20Token(address newBrc20) external {
        require(msg.sender == _admin && newBrc20 != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        if (_gmToken != newBrc20) {
            _gmToken = newBrc20;
        }
    }

    function changeBfs(address newBfs) external {
        require(msg.sender == _admin && newBfs != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        if (_bfs != newBfs) {
            _bfs = newBfs;
        }
    }

    /* @Mint */
    function tokenIdToHash(uint256 tokenId) external view returns (bytes32) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        if (_ownersAndHashSeeds[tokenId]._seed == 0) {
            return 0;
        }
        return keccak256(abi.encode(_ownersAndHashSeeds[tokenId]._seed));
    }

    function getMessageHash(address user, uint256 totalGM) public view returns (bytes32) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return keccak256(abi.encode(address(this), chainId, _signerMint, user, _gmToken, totalGM));
    }

    function _verifySigner(address user, uint256 totalGM, bytes memory signature) internal view returns (address, bytes32) {
        bytes32 messageHash = getMessageHash(user, totalGM);
        address signer = ECDSAUpgradeable.recover(ECDSAUpgradeable.toEthSignedMessageHash(messageHash), signature);
        // GP_NA: Signer Is Not ADmin
        require(signer == _signerMint, "GP_NA");
        return (signer, messageHash);
    }

    function mint(address to, address user, uint256 totalGM, bytes calldata signature) public payable nonReentrant returns (uint256 tokenId) {
        require(_currentId < _maxSupply, Errors.REACH_MAX);
        if (msg.sender != _admin) {
            // verify sign if not deployer
            require(msg.sender == user, "GP_IU");
            _verifySigner(user, totalGM, signature);
        }
        _currentId++;
        tokenId = _currentId;
        _safeMint(to, tokenId);

        IRandomizer random = IRandomizer(_randomizerAddr);
        bytes32 seed = random.generateTokenHash(tokenId);
        _setTokenSeed(tokenId, seed);
        _mintAt[tokenId] = block.number;
    }

    function batchMint(address to, uint256 n, bytes calldata signatures) external payable returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](n);
        require(msg.sender == _admin);
        // only deployer
        for (uint256 i = 0; i < n; i++) {
            uint256 tokenId = mint(to, address(0), 0, signatures);
            tokenIds[i] = tokenId;
            _mintAt[tokenId] = block.number;
            if (gasleft() < 200000) {break;}
        }
        return tokenIds;
    }

    function _setTokenSeed(uint256 tokenId, bytes32 seed) internal {
        require(_ownersAndHashSeeds[tokenId]._seed == bytes12(0), Errors.TOKEN_HAS_SEED);
        require(seed != bytes12(0), Errors.ZERO_SEED);
        _ownersAndHashSeeds[tokenId]._seed = bytes12(seed);
    }

    /* @ClaimOrAuction to get orphan token id */
    function claimable(uint256 tokenId) public view virtual returns (bool) {
        // check gm balance
        address owner = ownerOf(tokenId);
        uint256 balanceOwner = _getBalanceToken(owner);
        uint256 balanceClaimer = _getBalanceToken(msg.sender);

        // by threshold on config
        uint256 threshold = _getTokenThreshold();
        if (balanceOwner < threshold && balanceClaimer >= threshold) {
            return true;
        }
        return false;
    }

    function _getBlockReserve() internal returns (uint256) {
        uint256 blockReserve = IParameterControl(_paramsAddress).getUInt256("GM_RESERVE");
        if (blockReserve == 0) {
            // ~block in 7 day, 1 block 10 minute
            blockReserve = 60 * 24 * 7 / 10;
        }
        return blockReserve;
    }

    function _getBalanceToken(address owner) private view returns (uint256) {
        return IERC20Upgradeable(_gmToken).balanceOf(owner);
    }

    function _getTokenThreshold() private view returns (uint256) {
        uint256 threshold = IParameterControl(_paramsAddress).getUInt256("GM_THRESHOLD");
        if (threshold == 0) {
            threshold = 1 * 10 ** 18;
        }
        return threshold;
    }

    function _isContract(address _addr) private returns (bool isContract){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    // New solution -> Auction
    function settleAuction(uint256 tokenId) external override nonReentrant {
        if (msg.sender == ownerOf(tokenId)) {
            uint256 balance = _getBalanceToken(msg.sender);
            uint256 threshold = _getTokenThreshold();
            require(balance >= threshold, "balance GM < threshold");
        }
        _settleAuction(tokenId, msg.sender == ownerOf(tokenId));
    }

    function _settleAuction(uint256 tokenId, bool tokenOwner) internal {
        require(_auctions[tokenId].startTime != 0, "Auction hasn't begun");
        require(!_auctions[tokenId].settled, 'Auction has already been settled');
        if (!tokenOwner) {
            require(block.timestamp >= _auctions[tokenId].endTime, "Auction hasn't completed");
            _auctions[tokenId].settled = true;
            _auctions[tokenId].startTime = 0;

            // transfer token for winner
            if (_auctions[tokenId].bidder != address(0)) {
                transferFrom(ownerOf(tokenId), _auctions[tokenId].bidder, _auctions[tokenId].tokenId);
            }

            // transfer amount to treasury
            if (_auctions[tokenId].amount > 0) {
                address GMDAOTreasury = IParameterControl(_paramsAddress).getAddress("SOUL_AUCTION_GM_DAO_Treasury");
                require(GMDAOTreasury != address(0));
                // transfer 90%
                IERC20Upgradeable(_auctions[tokenId].erc20Token).transfer(GMDAOTreasury, _auctions[tokenId].amount * 9000 / 10000);
                _bidders[tokenId][_auctions[tokenId].bidder] = 0;
            }

            emit AuctionSettled(_auctions[tokenId].tokenId, _auctions[tokenId].bidder, _auctions[tokenId].amount);
        } else {
            require(block.timestamp < _auctions[tokenId].endTime, "Auction hasn't completed");
            _auctions[tokenId].settled = true;
            _auctions[tokenId].startTime = 0;

            // transfer amount to last bidder
            if (_auctions[tokenId].amount > 0) {
                IERC20Upgradeable(_auctions[tokenId].erc20Token).transfer(_auctions[tokenId].bidder, _auctions[tokenId].amount);
            }

            emit AuctionClosed(_auctions[tokenId].tokenId);
        }
    }

    function _createAuction(uint256 tokenId) internal {
        require(_exists(tokenId));
        require(_auctions[tokenId].settled || _auctions[tokenId].tokenId == 0, "Auction has already been settled or 1st Auction of token");
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _getBlockReserve();

        IParameterControl p = IParameterControl(_paramsAddress);
        AuctionHouse.Auction memory auction;
        auction.tokenId = tokenId;
        auction.erc20Token = p.getAddress("SOUL_AUCTION_ERC20_TOKEN");
        auction.amount = 0;
        auction.startTime = startTime;
        auction.endTime = endTime;
        auction.bidder = payable(msg.sender);
        auction.settled = false;
        auction.timeBuffer = p.getUInt256("SOUL_AUCTION_TIME_BUFFER");
        auction.reservePrice = p.getUInt256("SOUL_AUCTION_RESERVE_PRICE");
        auction.minBidIncrementPercentage = p.getUInt256("SOUL_AUCTION_MIN_BID_INCREASE_PERCENT");
        _auctions[tokenId] = auction;

        emit AuctionCreated(tokenId, startTime, endTime);
    }

    function createAuction(uint256 tokenId) external nonReentrant {
        require(claimable(tokenId), "N_C0");
        // 1 wallet 1 token
        require(balanceOf(msg.sender) == 0, "N_C0_2");
        _createAuction(tokenId);
    }

    function createBid(uint256 tokenId, uint256 amount) external payable override nonReentrant {
        require(claimable(tokenId), "N_C0");
        // 1 wallet 1 token
        require(balanceOf(msg.sender) == 0, "N_C0_2");

        IERC20Upgradeable erc20 = IERC20Upgradeable(_auctions[tokenId].erc20Token);

        uint256 currentAmount = _bidders[tokenId][msg.sender];
        uint256 newAmount = amount + currentAmount;
        require(_auctions[tokenId].tokenId == tokenId, 'not up for auction');
        require(block.timestamp < _auctions[tokenId].endTime, 'Auction expired');
        require(erc20.allowance(msg.sender, address(this)) >= amount, "not enough allow erc20 token");
        require(erc20.balanceOf(msg.sender) >= amount, "not enough erc20 token");
        require(newAmount >= _auctions[tokenId].reservePrice, 'Must send at least reservePrice');
        require(
            newAmount >= _auctions[tokenId].amount + ((_auctions[tokenId].amount * _auctions[tokenId].minBidIncrementPercentage) / 100),
            'Must send more than last bid by minBidIncrementPercentage amount'
        );
        // transfer amount to this contract
        require(erc20.transferFrom(msg.sender, address(this), amount), "can not get erc20 from bidder");

        // DEPRECATED - Refund the last bidder, if applicable
        /*address payable lastBidder = _auction.bidder;
        if (lastBidder != address(0)) {
            erc20.transfer(lastBidder, _auction.amount);
        }*/
        // => store list bidder with new amount
        _bidders[tokenId][msg.sender] = newAmount;

        // set new winner(the current highest bid)
        _auctions[tokenId].amount = newAmount;
        _auctions[tokenId].bidder = payable(msg.sender);

        // Extend the auction if the bid was received within `timeBuffer` of the auction end time
        bool extended = _auctions[tokenId].endTime - block.timestamp < _auctions[tokenId].timeBuffer;
        if (extended) {
            _auctions[tokenId].endTime = _auctions[tokenId].endTime = block.timestamp + _auctions[tokenId].timeBuffer;
        }

        emit AuctionBid(_auctions[tokenId].tokenId, msg.sender, msg.value, extended);

        if (extended) {
            emit AuctionExtended(_auctions[tokenId].tokenId, _auctions[tokenId].endTime);
        }
    }

    function claimBid(uint256 tokenId) external override nonReentrant {
        require(_auctions[tokenId].settled);
        require(_auctions[tokenId].bidder != msg.sender);
        require(_bidders[tokenId][msg.sender] > 0);
        IERC20Upgradeable(_auctions[tokenId].erc20Token).transfer(msg.sender, _bidders[tokenId][msg.sender]);
        emit AuctionClaimBid(tokenId, msg.sender, _bidders[tokenId][msg.sender]);
    }

    /* @Override on ERC-721*/
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
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
        /*super._burn(tokenId);
        delete _ownersAndHashSeeds[tokenId]._owner;*/
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual override returns (bool) {
        /*address owner = ownerOf(tokenId);
        if (spender != owner) {// case approved
            uint256 balance = _getBalanceToken(owner);
            uint256 threshold = _getTokenThreshold();
            if (balance < threshold) {
                return false;
            }
        }
        return super._isApprovedOrOwner(spender, tokenId);*/
        return false;
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        if (msg.sender == from) {
            // is current owner
            require(1 == 0, "T");
        } else {
            // marketplace(contract) or claimer
            if (_isContract(msg.sender)) {
                require(1 == 0, "T_1");
            } else {
                // require(1 == 0, "T_2");
                require(_auctions[tokenId].settled);
                require(_auctions[tokenId].bidder == to);
            }
        }
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        if (msg.sender == from) {
            // is current owner
            require(1 == 0, "T");
        } else {
            // marketplace(contract) or claimer
            if (_isContract(msg.sender)) {
                require(1 == 0, "T_1");
            } else {
                //require(1 == 0, "T_2");
                require(_auctions[tokenId].settled);
                require(_auctions[tokenId].bidder == to);
            }
        }
        _safeTransfer(from, to, tokenId, data);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual override {
        super._transfer(from, to, tokenId);
        _ownersAndHashSeeds[tokenId]._owner = to;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory result) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        bytes32 seed = this.tokenIdToHash(tokenId);

        IParameterControl param = IParameterControl(_paramsAddress);
        string memory html = this.tokenHTML(seed, tokenId);
        html = string(abi.encodePacked('data:text/html;base64,', Base64.encode(abi.encodePacked(html))));

        string memory _animationURI = string(abi.encodePacked(', "animation_url":"', html, '"'));
        string memory _baseURI = param.get(GenerativeProjectDataConfigs.BASE_URI_TRAIT);
        _baseURI = string(abi.encodePacked(_baseURI, "/",
            StringsUpgradeable.toHexString(address(this)), "/",
            StringsUpgradeable.toString(tokenId), "?seed=", StringsUtils.toHex(seed)));
        result = string(
            abi.encodePacked(
                '{"name":"","description": ""',
                ', "image": "', _baseURI, '&capture=60000"',
                _animationURI,
                ', "attributes": "', _baseURI, '&capture=0"',
                '}'
            )
        );
    }

    function p5jsScript() public view returns (string memory result) {
        result = "<script sandbox='allow-scripts' type='text/javascript'>";

        BFS bfs = BFS(_bfs);
        string memory fileName = "p5js@1.5.0.js";
        // count file
        IParameterControl param = IParameterControl(_paramsAddress);
        address scriptProvider = param.getAddress("SCRIPT_PROVIDER");
        uint256 count = bfs.count(scriptProvider, fileName);
        count += 1;
        // load and concat string
        for (uint256 i = 0; i < count; i++) {
            (bytes memory data, int256 nextChunk) = bfs.load(_admin, fileName, i);
            result = string(abi.encodePacked(result, string(data)));
        }
        result = string(abi.encodePacked(result, "</script>"));
        return result;
    }

    function web3Script() public view returns (string memory result) {
        result = "<script sandbox='allow-scripts' type='text/javascript'>";

        BFS bfs = BFS(_bfs);
        string memory fileName = "web3js@1.2.7.js";
        // count file
        IParameterControl param = IParameterControl(_paramsAddress);
        address scriptProvider = param.getAddress("SCRIPT_PROVIDER");
        uint256 count = bfs.count(scriptProvider, fileName);
        count += 1;
        // load and concat string
        for (uint256 i = 0; i < count; i++) {
            (bytes memory data, int256 nextChunk) = bfs.load(_admin, fileName, i);
            result = string(abi.encodePacked(result, string(data)));
        }
        result = string(abi.encodePacked(result, "</script>"));
        return result;
    }

    function variableScript(bytes32 seed, uint256 tokenId) public view returns (string memory result) {
        result = "<script id='vars'>";
        result = string(abi.encodePacked(result, "let seed='", StringsUtils.toHex(seed), "';"));
        result = string(abi.encodePacked(result, "let GM_CONTRACT_ADDRESS='", StringsUpgradeable.toHexString(_gmToken), "';"));
        IParameterControl param = IParameterControl(_paramsAddress);
        address SWAP_POOL_GM_ETH_CONTRACT_ADDRESS = param.getAddress("SWAP_POOL_GM_ETH_CONTRACT_ADDRESS");
        result = string(abi.encodePacked(result, "let SWAP_POOL_GM_ETH_CONTRACT_ADDRESS='", StringsUpgradeable.toHexString(SWAP_POOL_GM_ETH_CONTRACT_ADDRESS), "';"));
        result = string(abi.encodePacked(result, "let solarisNftContractAddress='", StringsUpgradeable.toHexString(address(this)), "';"));
        result = string(abi.encodePacked(result, "let TOKEN_ID='", StringsUpgradeable.toString(tokenId), "';"));
        result = string(abi.encodePacked(result, "</script>"));
    }

    function tokenHTML(bytes32 seed, uint256 tokenId) external view returns (string memory result) {
        result = "<html><head>";
        result = string(abi.encodePacked(result, p5jsScript()));
        result = string(abi.encodePacked(result, web3Script()));
        result = string(abi.encodePacked(result, variableScript(seed, tokenId)));
        result = string(abi.encodePacked(result, _script));

    }

    /** @dev EIP2981 royalties implementation. */
    // EIP2981 standard royalties return.
    function royaltyInfo(uint256 projectId, uint256 _salePrice) external view override
    returns (address receiver, uint256 royaltyAmount){
        receiver = _admin;
        royaltyAmount = (_salePrice * 500) / Royalty.MINT_PERCENT_ROYALTY;
    }
}
