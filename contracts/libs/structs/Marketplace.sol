pragma solidity ^0.8.0;

library Marketplace {
    event OfferingPlaced(bytes32 indexed offeringId, address indexed hostContract, address indexed offerer, uint tokenId, uint price);
    event OfferingClosed(bytes32 indexed offeringId, address indexed buyer);
    event BalanceWithdrawn (address indexed beneficiary, uint amount);
    event OperatorChanged (address previousOperator, address newOperator);
    event ParameterControlChanged (address previousOperator, address newOperator);
    event ApprovalForAll(address owner, address operator, bool approved);

    struct Benefit {
        uint256 benefitPercentCreator;
        uint256 benefitCreator;
        uint256 benefitPercentOperator;
        uint256 benefitOperator;
        uint256 discountRoveToken;
    }

    struct Offering {
        address offerer;
        address hostContract;
        uint tokenId;
        uint price;
        bool closed;
        address erc20Token;
    }

    struct CloseOfferingData {
        address buyer;
        uint price;
        uint originPrice;
        uint256 balanceBuyer;
        uint256 approvalToken;
        address erc20Token;
    }
}
