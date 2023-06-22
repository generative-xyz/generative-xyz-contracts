pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";
import "../libs/structs/NFTCollection.sol";
import "../interfaces/IParameterControl.sol";
import "../libs/helpers/Base64.sol";
import "../libs/helpers/StringsUtils.sol";
import "../interfaces/IRandomizer.sol";
import "../services/BFS.sol";
import "../interfaces/IAuction.sol";
import "../libs/structs/Auction.sol";

contract SOUL is Initializable, ERC721PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, IERC2981Upgradeable, IAuction, IERC721ReceiverUpgradeable {
    address public _admin;
    address public _paramsAddress;
    address public _randomizerAddr;
    uint256 private _currentId;
    string public _script;
    address public _gmToken;
    address public _bfs;

    uint256 public _maxSupply;
    address public _signerMint;
    mapping(uint256 => NFTCollection.OwnerSeed) internal _ownersAndHashSeeds;
    mapping(uint256 => uint256) public _mintAt;
    mapping(address => uint256) public _minted;

    uint256 private _counting;
    // user -> erc20 -> amount
    mapping(address => mapping(address => uint256)) public _biddingBalance;
    // tokenId -> current auction
    mapping(uint256 => AuctionHouse.Auction) public _auctions;
    // auctionId -> auction
    mapping(bytes32 => AuctionHouse.Auction) public _auctionsList;
    // tokenId -> auctionId -> user -> bid amount 
    mapping(uint256 => mapping(bytes32 => mapping(address => uint256))) public _bidderAuctions;
    // erc20 -> amount
    mapping(address => uint256) public _coreTeamTreasury;
    // tokenId -> auctionId -> user[] 
    mapping(uint256 => mapping(bytes32 => address[])) public _bidderAuctionsList;

    mapping(uint256 => string) public _names;

    // tokenId -> user -> feature_name -> unlock bool
    mapping(uint256 => mapping(address => mapping(string => bool))) public _features;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramsAddress,
        address randomizerAddr,
        address gmToken,
        address bfs,
        address signerMint
    ) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(paramsAddress != Errors.ZERO_ADDR, Errors.INV_ADD);
        _paramsAddress = paramsAddress;
        _admin = admin;
        _randomizerAddr = randomizerAddr;
        _gmToken = gmToken;
        _maxSupply = 1247;
        _bfs = bfs;
        _signerMint = signerMint;

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

    function withdraw(address erc20Addr) external nonReentrant {
        IERC20Upgradeable erc20Token = IERC20Upgradeable(erc20Addr);
        if (msg.sender == _admin) {
            // core team
            require(_coreTeamTreasury[erc20Addr] > 0);
            require(erc20Token.transfer(msg.sender, _coreTeamTreasury[erc20Addr]), "W1");
            _coreTeamTreasury[erc20Addr] = 0;
        } else {
            // user
            require(_biddingBalance[msg.sender][erc20Addr] > 0);
            require(erc20Token.transfer(msg.sender, _biddingBalance[msg.sender][erc20Addr]), "W2");
            _biddingBalance[msg.sender][erc20Addr] = 0;
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

    function mint(address to, uint256 totalGM, bytes calldata signature) public nonReentrant returns (uint256 tokenId) {
        require(_currentId < _maxSupply, Errors.REACH_MAX);
        if (msg.sender != _admin) {
            require(msg.sender == to, "GP_IU");
            require(balanceOf(to) == 0, "1-1");
            require(_minted[to] == 0, "M");
            // verify sign if not deployer
            _verifySigner(to, totalGM, signature);
            _minted[to] = 1;
        } else {
            require(to != _admin, "GP_IU");
            if (to != address(this)) {
                require(balanceOf(to) == 0, "1-1");
                require(_minted[to] == 0, "M");
                _minted[to] = 1;
            }
        }
        _currentId++;
        tokenId = _currentId;
        _safeMint(to, tokenId);

        IRandomizer random = IRandomizer(_randomizerAddr);
        bytes32 seed = random.generateTokenHash(tokenId);
        _setTokenSeed(tokenId, seed);
        _mintAt[tokenId] = block.number;
    }

    function _setTokenSeed(uint256 tokenId, bytes32 seed) internal {
        require(_ownersAndHashSeeds[tokenId]._seed == bytes12(0), Errors.TOKEN_HAS_SEED);
        require(seed != bytes12(0), Errors.ZERO_SEED);
        _ownersAndHashSeeds[tokenId]._seed = bytes12(seed);
    }

    function setName(uint256 tokenId, string memory name) public nonReentrant {
        require(msg.sender == ownerOf(tokenId));
        _names[tokenId] = name;
    }

    /* @Auction to get orphan token id */
    function deposit(uint256 amount) public payable nonReentrant {
        address erc20Token = IParameterControl(_paramsAddress).getAddress("SOUL_AUCTION_ERC20_TOKEN");
        if (erc20Token == address(0)) {
            erc20Token = _gmToken;
        }

        IERC20Upgradeable erc20 = IERC20Upgradeable(erc20Token);
        require(erc20.allowance(msg.sender, address(this)) >= amount, "not enough allow erc20 token");
        require(erc20.balanceOf(msg.sender) >= amount, "not enough erc20 token");

        // transfer amount to this contract
        require(erc20.transferFrom(msg.sender, address(this), amount), "can not get erc20 from bidder");
        _biddingBalance[msg.sender][erc20Token] += amount;
    }

    function available(uint256 tokenId) public view virtual returns (bool) {
        if (!_exists(tokenId)) {
            return false;
        }
        if (block.number - _mintAt[tokenId] <= _getBlockReserve()) {
            return false;
        }
        if (ownerOf(tokenId) == _admin) {
            return false;
        }
        if (ownerOf(tokenId) == address(this)) {
            // orphan token
            if (_auctions[tokenId].settled) {
                // auction is settled
                return true;
            }
        }
        // check gm balance
        // by threshold on config
        uint256 threshold = _getTokenThreshold();
        if (_getBalanceToken(ownerOf(tokenId)) < threshold) {
            return true;
        }
        return false;
    }

    function biddable(address walletAddress) public view virtual returns (bool) {
        if (balanceOf(walletAddress) > 0) {
            return false;
        }
        // check gm balance
        // by threshold on config
        address erc20Token = IParameterControl(_paramsAddress).getAddress("SOUL_AUCTION_ERC20_TOKEN");
        if (erc20Token == address(0)) {
            erc20Token = _gmToken;
        }
        if (_getBalanceToken(walletAddress) + _biddingBalance[walletAddress][erc20Token] >= _getTokenThreshold()) {
            return true;
        }
        return false;
    }

    function _getBlockReserve() internal view returns (uint256) {
        uint256 blockReserve = IParameterControl(_paramsAddress).getUInt256("SOUL_GM_RESERVE");
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
        uint256 threshold = IParameterControl(_paramsAddress).getUInt256("SOUL_GM_THRESHOLD");
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
        _settleAuction(tokenId, msg.sender == ownerOf(tokenId));
    }

    function _settleAuction(uint256 tokenId, bool tokenOwner) internal {
        bytes32 auctionId = _auctions[tokenId].auctionId;

        require(_auctions[tokenId].startTime != 0, "Auction hasn't begun");
        require(!_auctions[tokenId].settled, 'Auction has already been settled');
        require(block.number >= _auctions[tokenId].endTime, "Auction hasn't completed");
        // _auctions[tokenId].startTime = 0;
        _auctions[tokenId].settled = true;
        _auctionsList[auctionId].settled = true;

        // transfer token for winner
        bool backWinner = false;
        if (_auctions[tokenId].bidder != address(0)) {
            if (balanceOf(_auctions[tokenId].bidder) == 0) {
                // only transfer when winner balance = 0 -> can not cheat on >= 1 auction
                _transfer(address(this), _auctions[tokenId].bidder, _auctions[tokenId].tokenId);
            } else {
                // refund bidding amount for winner
                // add back to balance 
                _biddingBalance[_auctions[tokenId].bidder][_auctions[tokenId].erc20Token] += _auctions[tokenId].amount;
                // reset on history
                _bidderAuctions[tokenId][auctionId][_auctions[tokenId].bidder] = 0;
                backWinner = true;
            }
        }

        // transfer amount to treasury
        if (_auctions[tokenId].amount > 0 && !backWinner) {
            address GMDAOTreasury = IParameterControl(_paramsAddress).getAddress("SOUL_AUCTION_GM_DAO_Treasury");
            require(GMDAOTreasury != address(0));
            uint256 coreTeamTreasuryAmount = _auctions[tokenId].amount * 1000 / 10000;
            // transfer 90% to DAO treasury
            IERC20Upgradeable(_auctions[tokenId].erc20Token).transfer(GMDAOTreasury, _auctions[tokenId].amount - coreTeamTreasuryAmount);
            _coreTeamTreasury[_auctions[tokenId].erc20Token] += coreTeamTreasuryAmount;
            // reset to 0 for winner on bidders list
            _bidderAuctions[tokenId][auctionId][_auctions[tokenId].bidder] = 0;
        }

        // loop for auto _claimBid
        if (_bidderAuctionsList[tokenId][auctionId].length > 0) {
            for (uint256 i = 0; i < _bidderAuctionsList[tokenId][auctionId].length; i++) {
                if (_bidderAuctionsList[tokenId][auctionId][i] != _auctions[tokenId].bidder) {
                    _claimBid(_bidderAuctionsList[tokenId][auctionId][i], tokenId, auctionId);
                }
            }
        }


        emit AuctionSettled(_auctions[tokenId].tokenId, _auctions[tokenId].bidder, _auctions[tokenId].amount, _auctions[tokenId]);
    }

    function _createAuction(uint256 tokenId) internal {
        require(_auctions[tokenId].settled || _auctions[tokenId].tokenId == 0, "Auction has already been settled or 1st Auction of token");
        uint256 startTime = block.number;
        uint256 endTime = startTime + _getBlockReserve();

        IParameterControl p = IParameterControl(_paramsAddress);
        AuctionHouse.Auction memory auction;
        auction.tokenId = tokenId;
        auction.erc20Token = p.getAddress("SOUL_AUCTION_ERC20_TOKEN");
        if (auction.erc20Token == address(0)) {
            auction.erc20Token = _gmToken;
        }
        auction.amount = 0;
        auction.startTime = startTime;
        auction.endTime = endTime;
        auction.bidder = payable(address(0));
        auction.settled = false;
        auction.timeBuffer = p.getUInt256("SOUL_AUCTION_TIME_BUFFER");
        auction.reservePrice = p.getUInt256("SOUL_AUCTION_RESERVE_PRICE");
        auction.minBidIncrementPercentage = p.getUInt256("SOUL_AUCTION_MIN_BID_INCREASE_PERCENT");
        // create auctionId by counter
        _counting++;
        auction.auctionId = keccak256(abi.encodePacked(StringsUpgradeable.toString(_counting), StringsUpgradeable.toString(auction.startTime), StringsUpgradeable.toString(auction.endTime), StringsUpgradeable.toString(tokenId)));
        _auctions[tokenId] = auction;
        _auctionsList[auction.auctionId] = auction;

        // transfer token to this contract as orphan token
        if (ownerOf(tokenId) != address(this)) {
            _transfer(ownerOf(tokenId), address(this), tokenId);
        }

        emit AuctionCreated(tokenId, startTime, endTime, msg.sender, auction.auctionId, auction);
    }

    function createAuction(uint256 tokenId) external nonReentrant {
        require(available(tokenId), "N_C0");
        address oldOwner = ownerOf(tokenId);
        _createAuction(tokenId);

        if (oldOwner != address(this)) {
            // reset _features
            (string[10] memory featuresSetting, uint16[10] memory balancesSetting, uint16[10] memory holdTimesSetting) = getSettingFeatures();
            for (uint256 i; i < featuresSetting.length; i++) {
                _features[tokenId][oldOwner][featuresSetting[i]] = false;
            }
        }

    }

    function createBid(uint256 tokenId, uint256 amount) external override nonReentrant {
        require(biddable(msg.sender), "N_C0");
        // 1 wallet 1 token
        require(balanceOf(msg.sender) == 0, "N_C0_2");

        if (_bidderAuctions[tokenId][_auctions[tokenId].auctionId][msg.sender] == 0) {
            // new bidder
            _bidderAuctionsList[tokenId][_auctions[tokenId].auctionId].push(msg.sender);
        }

        require(_auctions[tokenId].tokenId == tokenId, 'not up for auction');
        require(block.number < _auctions[tokenId].endTime, 'Auction expired');
        require(_biddingBalance[msg.sender][_auctions[tokenId].erc20Token] >= amount, "not enough balance erc20 token");

        uint256 currentAmount = _bidderAuctions[tokenId][_auctions[tokenId].auctionId][msg.sender];
        uint256 newAmount = amount + currentAmount;
        require(newAmount > _auctions[tokenId].reservePrice, 'Must send at least reservePrice');
        require(newAmount > _auctions[tokenId].amount + ((_auctions[tokenId].amount * _auctions[tokenId].minBidIncrementPercentage) / 100), 'Must send more than last bid by minBidIncrementPercentage amount');
        // get amount from balance
        _biddingBalance[msg.sender][_auctions[tokenId].erc20Token] -= amount;

        // => store list bidder with new amount
        _bidderAuctions[tokenId][_auctions[tokenId].auctionId][msg.sender] = newAmount;

        // set new winner(the current highest bid)
        _auctions[tokenId].amount = newAmount;
        _auctions[tokenId].bidder = payable(msg.sender);
        // copy to history
        _auctionsList[_auctions[tokenId].auctionId].amount = _auctions[tokenId].amount;
        _auctionsList[_auctions[tokenId].auctionId].bidder = _auctions[tokenId].bidder;

        // Extend the auction if the bid was received within `timeBuffer` of the auction end time
        bool extended = _auctions[tokenId].endTime - block.number < _auctions[tokenId].timeBuffer;
        if (extended) {
            _auctions[tokenId].endTime = block.number + _auctions[tokenId].timeBuffer;
        }

        emit AuctionBid(_auctions[tokenId].tokenId, msg.sender, amount, extended, _auctions[tokenId]);

        if (extended) {
            emit AuctionExtended(_auctions[tokenId].tokenId, _auctions[tokenId].endTime, _auctions[tokenId]);
        }
    }

    /*function claimBid(uint256 tokenId, bytes32 auctionId) external override nonReentrant {
        _claimBid(msg.sender, tokenId, auctionId);
    }*/

    function _claimBid(address claimer, uint256 tokenId, bytes32 auctionId) internal {
        require(_auctionsList[auctionId].settled);
        require(_auctionsList[auctionId].bidder != claimer);
        require(_bidderAuctions[tokenId][auctionId][claimer] > 0);

        emit AuctionClaimBid(tokenId, claimer, _bidderAuctions[tokenId][auctionId][claimer], auctionId);

        // add back to balance 
        _biddingBalance[claimer][_auctionsList[auctionId].erc20Token] += _bidderAuctions[tokenId][auctionId][claimer];
        // reset on history
        _bidderAuctions[tokenId][auctionId][claimer] = 0;
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
        require(1 == 0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual override returns (bool) {
        return false;
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(1 == 0);
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(1 == 0);
        _safeTransfer(from, to, tokenId, data);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual override {
        if (to != address(this)) {
            require(balanceOf(to) == 0);
        }
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
        result = string(
            abi.encodePacked(
                '{"name":"', _names[tokenId], '","description": ""',
                ', "image": ""',
                _animationURI,
                ', "attributes": ""',
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
        result = string(abi.encodePacked(result, "let soulNftContractAddress='", StringsUpgradeable.toHexString(address(this)), "';"));
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

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }

    /* @Features: unlock new feature from SOUL
    */
    function canUnlockFeature(uint256 tokenId, address user, string memory featureName) public view returns (bool) {
        bool currentState = _features[tokenId][user][featureName];
        if (currentState) {
            return false;
        }
        uint256 userBalance = IERC20Upgradeable(_gmToken).balanceOf(user);

        (string memory featureSetting, uint256 balanceSetting, uint256 holdTimeSetting) = getSettingFeature(featureName);
        if (bytes(featureSetting).length == 0) {
            return false;
        }
        if (userBalance >= (balanceSetting * 10 ** 18)) {
            if (block.number - _mintAt[tokenId] >= holdTimeSetting) {
                return true;
            }
        }

        return false;
    }

    function unlockFeature(uint256 tokenId, string memory featureName) public nonReentrant {
        require(canUnlockFeature(tokenId, msg.sender, featureName));
        require(ownerOf(tokenId) == msg.sender);
        _features[tokenId][msg.sender][featureName] = true;
    }

    function getSettingFeatures() public view returns (string[10] memory features, uint16[10] memory balances, uint16[10] memory holdTimes) {
        features = [
        "feature_suneffect",
        "feature_cloudlayer",
        "feature_foreground",
        "feature_decor",
        "feature_rainbow",
        "feature_sunpillar",
        "feature_specialobj",
        "feature_thunder",
        "feature_rain",
        "feature_sunaura"
        ];

        balances = [20, 30, 50, 80, 100, 100, 200, 300, 500, 800];
        holdTimes = [1000, 2000, 3000, 5000, 8000, 10000, 10000, 10000, 10000, 10000];
    }

    function getSettingFeature(string memory featureName) private view returns (string memory, uint256, uint256) {
        (string[10] memory features, uint16[10] memory balances, uint16[10] memory holdTimes) = getSettingFeatures();
        for (uint16 i = 0; i < features.length; i++) {
            if (keccak256(abi.encodePacked((featureName))) == keccak256(abi.encodePacked((features[i])))) {
                return (features[i], balances[i], holdTimes[i]);
            }
        }
        return ("", 0, 0);
    }
}
