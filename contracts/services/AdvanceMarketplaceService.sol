pragma solidity ^0.8.0;

import "./SimpleMarketplaceService.sol";

contract AdvanceMarketplaceService is SimpleMarketplaceService {

    function initialize(address admin, address parameterControl) initializer override public {
        super.initialize(admin, parameterControl);
    }
}
