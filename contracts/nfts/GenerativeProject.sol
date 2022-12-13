pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "../interfaces/IGenerativeProject.sol";
import "../libs/helpers/Errors.sol";
import "../interfaces/IParameterControl.sol";
import "../interfaces/IGenerativeNFT.sol";

contract GenerativeProject is Initializable, ERC721PausableUpgradeable, ReentrancyGuardUpgradeable, IERC2981Upgradeable, IGenerativeProject {

    // super admin
    address public _admin;
    // parameter control address
    address public _paramsAddress;
    // randomizer
    address public _randomizerAddr;

    // projectId is tokenID of project nft
    uint256 private _currentProjectId;

    mapping(uint256 => NFTProject.Project) _projects;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramsAddress
    ) initializer public {
        require(admin != address(0), Errors.INV_ADD);
        require(paramsAddress != address(0), Errors.INV_ADD);
        __ERC721_init(name, symbol);
        _paramsAddress = paramsAddress;
        _admin = admin;
    }

    function changeAdmin(address newAdm, address newParam) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            address _previousAdmin = _admin;
            _admin = newAdm;
        }

        // change param
        require(newParam != address(0));
        if (_paramsAddress != newParam) {
            _paramsAddress = newParam;
        }
    }

    function paymentMintProject() internal {
        if (msg.sender != _admin) {
            IParameterControl _p = IParameterControl(_paramsAddress);
            // at least require value 1ETH
            uint256 operationFee = _p.getUInt256("CREATE_PROJECT_FEE");
            if (operationFee > 0) {
                address operationFeeToken = _p.getAddress("FEE_TOKEN");
                if (!(operationFeeToken == address(0))) {
                    IERC20Upgradeable tokenERC20 = IERC20Upgradeable(operationFeeToken);
                    // transfer erc-20 token to this contract
                    require(tokenERC20.transferFrom(
                            msg.sender,
                            address(this),
                            operationFee
                        ));
                } else {
                    require(msg.value >= operationFee);
                }
            }
        }
    }

    function createProject(address[] memory reserves) external returns (uint256) {
        _currentProjectId++;
        IParameterControl _p = IParameterControl(_paramsAddress);
        paymentMintProject();
        NFTProject.Project storage project;
        _safeMint(msg.sender, _currentProjectId);
        address generativeNFTAdd = ClonesUpgradeable.clone(_p.getAddress("GENERATIVE_NFT_TEMPLATE"));
        IGenerativeNFT nft = IGenerativeNFT(generativeNFTAdd);
        NFTProject.ProjectData memory data;

        nft.init(data, _admin, _paramsAddress, _randomizerAddr, reserves);
        return _currentProjectId;
    }

    function completeProject(uint256 projectId) external {
        require(msg.sender == _projects[projectId]._genNFTAddr);
        _projects[projectId]._completeTime = block.timestamp;
    }

    /** @dev EIP2981 royalties implementation. */
    // EIP2981 standard royalties return.
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override
    returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _admin;
        royaltyAmount = (_salePrice * 500) / 10000;
    }
}
