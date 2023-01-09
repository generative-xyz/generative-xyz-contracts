pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../libs/helpers/Errors.sol";

contract GENToken is Initializable, ERC20PresetMinterPauserUpgradeable, OwnableUpgradeable {
    address public _admin;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        uint256 initSupply
    ) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;

        // init supply
        // 100 mil with decimals = 4 for testnet
        // 0 with decimal = 4 for mainnet
        uint256 _totalSupplyRove = initSupply;
        mint(admin, _totalSupplyRove);

        __ERC20PresetMinterPauser_init(name, symbol);
        __Ownable_init();
    }

    function changeAdmin(address _newAdmin) external {
        require(_newAdmin != Errors.ZERO_ADDR && _newAdmin != _admin, Errors.INV_ADD);
        _admin = _newAdmin;
    }

    function decimals() public pure override returns (uint8) {
        return 4;
    }

    /** ControlSupply
    **/
    function mint(address to, uint256 amount) public whenNotPaused override {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _mint(to, amount);
    }

    function mintByBlock(address to) external whenNotPaused virtual {
        // TODO
        require(1 == 0);
        _mint(to, 0);
    }
}
