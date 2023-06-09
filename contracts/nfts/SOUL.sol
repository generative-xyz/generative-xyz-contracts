pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";

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
    address public _brc20Token;
    uint256 public _maxSupply;
    mapping(uint256 => mapping(address => uint256)) public _reservations;

    mapping(uint256 => NFTCollection.OwnerSeed) internal _ownersAndHashSeeds;

    address public _bfs;

    mapping(uint256 => AuctionHouse.Auction) _auctions;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramsAddress,
        address randomizerAddr,
        address gmToken
    ) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(paramsAddress != Errors.ZERO_ADDR, Errors.INV_ADD);
        _paramsAddress = paramsAddress;
        _admin = admin;
        _randomizerAddr = randomizerAddr;
        _brc20Token = gmToken;
        _maxSupply = 1000;

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

        if (_brc20Token != newBrc20) {
            _brc20Token = newBrc20;
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

    function mint(address to) public payable nonReentrant returns (uint256 tokenId) {
        require(_currentId < _maxSupply, Errors.REACH_MAX);
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _currentId++;
        tokenId = _currentId;
        _safeMint(to, tokenId);

        IRandomizer random = IRandomizer(_randomizerAddr);
        bytes32 seed = random.generateTokenHash(tokenId);
        _setTokenSeed(tokenId, seed);
    }

    function batchMint(address to, uint256 n) external payable returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            uint256 tokenId = mint(to);
            tokenIds[i] = tokenId;
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
        return IERC20Upgradeable(_brc20Token).balanceOf(owner);
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

    // Old solution for orphan tokenid: reserve and claim
    /*function reserve(uint256 tokenId) external payable nonReentrant {
        require(claimable(tokenId), "N_C0");
        // 1 wallet 1 token
        require(balanceOf(msg.sender) == 0, "N_C0_2");

        uint256 blockReserve = _getBlockReserve();
        uint256 reservation = _reservations[tokenId][msg.sender];
        require(reservation == 0 || block.number - reservation >= blockReserve, "N_C0_1");

        _reservations[tokenId][msg.sender] = block.number;

        emit Reserve(msg.sender, tokenId, ownerOf(tokenId), block.number);
    }*/
    /*function claim(uint256 tokenId) external payable nonReentrant {
        require(claimable(tokenId), "N_C1");
        // 1 wallet 1 token
        require(balanceOf(msg.sender) == 0, "N_C1_2");

        uint256 blockReserve = _getBlockReserve();
        uint256 reservation = _reservations[tokenId][msg.sender];
        require(reservation > 0 && block.number - reservation >= blockReserve, "N_C1_1");

        address owner = ownerOf(tokenId);
        _transfer(owner, msg.sender, tokenId);

        delete _reservations[tokenId][msg.sender];

        emit Claim(msg.sender, tokenId, ownerOf(tokenId), block.number);
    }*/

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
        AuctionHouse.Auction memory _auction = _auctions[tokenId];

        require(_auction.startTime != 0, "Auction hasn't begun");
        require(!_auction.settled, 'Auction has already been settled');
        if (!tokenOwner) {
            require(block.timestamp >= _auction.endTime, "Auction hasn't completed");
            _auctions[tokenId].settled = true;
            _auction.startTime = 0;

            // transfer token for winner
            if (_auction.bidder != address(0)) {
                transferFrom(ownerOf(tokenId), _auction.bidder, _auction.tokenId);
            }

            // transfer amount to treasury
            if (_auction.amount > 0) {
                address GMDAOTreasury = IParameterControl(_paramsAddress).getAddress("SOUL_AUCTION_GM_DAO_Treasury");
                require(GMDAOTreasury != address(0));
                IERC20Upgradeable(_auction.erc20Token).transfer(GMDAOTreasury, _auction.amount);
            }

            emit AuctionSettled(_auction.tokenId, _auction.bidder, _auction.amount);
        } else {
            require(block.timestamp < _auction.endTime, "Auction hasn't completed");
            _auctions[tokenId].settled = true;
            _auction.startTime = 0;

            // transfer token for last bidder
            if (_auction.bidder != address(0)) {
                transferFrom(ownerOf(tokenId), _auction.bidder, _auction.tokenId);
            }
            emit AuctionClosed(_auction.tokenId);
        }
    }

    function _createAuction(uint256 tokenId) internal {
        require(_exists(tokenId));
        require(_auctions[tokenId].settled || _auctions[tokenId].tokenId == 0, "Auction has already been settled or 1st Auction of token");
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _getBlockReserve();

        IParameterControl p = IParameterControl(_paramsAddress);
        AuctionHouse.Auction memory auction = AuctionHouse.Auction({
        tokenId : tokenId,
        erc20Token : p.getAddress("SOUL_AUCTION_ERC20_TOKEN"),
        amount : 0,
        startTime : startTime,
        endTime : endTime,
        bidder : payable(0),
        settled : false,
        timeBuffer : p.getUInt256("SOUL_AUCTION_TIME_BUFFER"),
        reservePrice : p.getUInt256("SOUL_AUCTION_RESERVE_PRICE"),
        minBidIncrementPercentage : p.getUInt256("SOUL_AUCTION_MIN_BID_INCREASE_PERCENT")
        });
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

        AuctionHouse.Auction memory _auction = _auctions[tokenId];
        IERC20Upgradeable erc20 = IERC20Upgradeable(_auction.erc20Token);

        require(_auction.tokenId == tokenId, 'not up for auction');
        require(block.timestamp < _auction.endTime, 'Auction expired');
        require(erc20.allowance(msg.sender, address(this)) >= amount, "not enough allow erc20 token");
        require(erc20.balanceOf(msg.sender) >= amount, "not enough erc20 token");
        require(amount >= _auction.reservePrice, 'Must send at least reservePrice');
        require(
            amount >= _auction.amount + ((_auction.amount * _auction.minBidIncrementPercentage) / 100),
            'Must send more than last bid by minBidIncrementPercentage amount'
        );
        require(erc20.transferFrom(msg.sender, address(this), amount), "can not get erc20 from bidder");

        address payable lastBidder = _auction.bidder;

        // Refund the last bidder, if applicable
        if (lastBidder != address(0)) {
            erc20.transfer(lastBidder, _auction.amount);
        }

        _auctions[tokenId].amount = amount;
        _auctions[tokenId].bidder = payable(msg.sender);

        // Extend the auction if the bid was received within `timeBuffer` of the auction end time
        bool extended = _auction.endTime - block.timestamp < _auction.timeBuffer;
        if (extended) {
            _auctions[tokenId].endTime = _auction.endTime = block.timestamp + _auction.timeBuffer;
        }

        emit AuctionBid(_auction.tokenId, msg.sender, msg.value, extended);

        if (extended) {
            emit AuctionExtended(_auction.tokenId, _auction.endTime);
        }
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
            /*uint256 balance = _getBalanceToken(msg.sender);
            uint256 threshold = _getTokenThreshold();
            require(balance >= threshold, "T");*/
            require(1 == 0, "T");
        } else {
            // marketplace(contract) or claimer
            if (_isContract(msg.sender)) {
                /*require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
                // check balance GM of current owner
                uint256 balance = _getBalanceToken(from);
                uint256 threshold = _getTokenThreshold();
                require(balance >= threshold, "T_1");*/
                require(1 == 0, "T_1");
            } else {
                require(claimable(tokenId), "N_C2");
                uint256 blockReserve = _getBlockReserve();
                uint256 reservation = _reservations[tokenId][msg.sender];
                require(reservation > 0 && block.number - reservation >= blockReserve, "N_C1_1");
            }
        }
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        if (msg.sender == from) {
            // is current owner
            /*uint256 balance = _getBalanceToken(msg.sender);
            uint256 threshold = _getTokenThreshold();
            require(balance >= threshold, "T");*/
            require(1 == 0, "T");
        } else {
            // marketplace(contract) or claimer
            if (_isContract(msg.sender)) {
                /*require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
                // check balance GM of current owner
                uint256 balance = _getBalanceToken(from);
                uint256 threshold = _getTokenThreshold();
                require(balance >= threshold, "T_1");*/
                require(1 == 0, "T_1");
            } else {
                require(claimable(tokenId), "N_C2");
                uint256 blockReserve = _getBlockReserve();
                uint256 reservation = _reservations[tokenId][msg.sender];
                require(reservation > 0 && block.number - reservation >= blockReserve, "N_C1_1");
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
        result = string(abi.encodePacked(result, "let GM_CONTRACT_ADDRESS='", StringsUpgradeable.toHexString(_brc20Token), "';"));
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
