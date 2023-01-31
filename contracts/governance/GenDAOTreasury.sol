pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../libs/helpers/Errors.sol";

contract GenDAOTreasury is OwnableUpgradeable, ReentrancyGuardUpgradeable, IERC721ReceiverUpgradeable, IERC1155ReceiverUpgradeable {
    address public _admin;
    address public _param;
    address public _dao;

    function initialize(
        address admin, address paramAddr, address dao
    ) initializer public {
        _admin = admin;
        _param = paramAddr;
        _dao = dao;
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeParamAddress(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);
        // change param address
        if (_paramAddr != newAddr) {
            _paramAddr = newAddr;
        }
    }

    function changeDAOAddress(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);
        // change param address
        if (_dao != newAddr) {
            _dao = newAddr;
        }
    }

    function withdraw(address receiver, address erc20Addr, uint256 amount) external virtual nonReentrant {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        bool success;
        if (erc20Addr == address(0x0)) {
            require(address(this).balance >= amount);
            (success,) = receiver.call{value : amount}("");
            require(success);
        } else {
            IERC20Upgradeable tokenERC20 = IERC20Upgradeable(erc20Addr);
            // transfer erc-20 token
            require(tokenERC20.transfer(receiver, amount));
        }
    }

    function transferERC20(address to, address erc20Addr, uint256 amount) external virtual nonReentrant {
        require(msg.sender == _dao, Errors.ONLY_ADMIN_ALLOWED);
        IERC20Upgradeable tokenERC20 = IERC20Upgradeable(erc20Addr);
        require(tokenERC20.transfer(to, amount));
    }

    function transfer(address to, uint256 amount) external virtual nonReentrant {
        require(msg.sender == _dao, Errors.ONLY_ADMIN_ALLOWED);
        require(address(this).balance >= amount);
        (bool success,) = to.call{value : amount}("");
        require(success);
    }

    function transferERC721(address to, address collection, uint256 tokenId) external virtual nonReentrant {
        require(msg.sender == _dao, Errors.ONLY_ADMIN_ALLOWED);
        IERC721Upgradeable tokenERC721 = IERC721Upgradeable(collection);
        tokenERC721.safeTransferFrom(address(this), to, tokenId);
    }

    function transferERC721(address to, address collection, uint256 tokenId, uint256 amount) external virtual nonReentrant {
        require(msg.sender == _dao, Errors.ONLY_ADMIN_ALLOWED);
        IERC1155Upgradeable tokenERC1155 = IERC1155Upgradeable(collection);
        tokenERC1155.safeTransferFrom(address(this), to, tokenId, amount, "");
    }

    /**
     * @dev Function to receive ETH that will be handled by the governor (disabled if executor is a third party contract)
     */
    receive() external payable virtual {
    }

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }


    /**
     * @dev See {IERC1155Receiver-onERC1155Received}.
     */
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     * @dev See {IERC1155Receiver-onERC1155BatchReceived}.
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(IERC165Upgradeable)
    returns (bool)
    {
        return
        interfaceId == type(IERC165Upgradeable).interfaceId;
    }
}
