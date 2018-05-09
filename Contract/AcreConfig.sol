pragma solidity 0.4.20;

import "./SafeMath.sol";

contract AcreConfig {
    using SafeMath for uint;
    
    uint internal constant TIME_FACTOR = 1 days;

    // Ownable
    uint internal constant OWNERSHIP_DURATION_TIME = 7; // 7 days
    
    // MultiOwnable
    uint8 internal constant MULTI_OWNER_COUNT = 5; // 5 accounts, exclude master
    
    // Lockable
    uint internal constant LOCKUP_DURATION_TIME = 365; // 365 days
    
    // AcreToken
    string internal constant TOKEN_NAME            = "Acre";
    string internal constant TOKEN_SYMBOL          = "ACRE";
    uint8  internal constant TOKEN_DECIMALS        = 18;
    
    uint   internal constant INITIAL_SUPPLY        =   1*1e8 * 10 ** uint(TOKEN_DECIMALS); // supply
    uint   internal constant CAPITAL_SUPPLY        =  31*1e6 * 10 ** uint(TOKEN_DECIMALS); // supply
    uint   internal constant PRE_PAYMENT_SUPPLY    =  19*1e6 * 10 ** uint(TOKEN_DECIMALS); // supply
    uint   internal constant MAX_MINING_SUPPLY     =   4*1e8 * 10 ** uint(TOKEN_DECIMALS); // supply
    
    // Sale
    uint internal constant MIN_ETHER               = 1*1e17; // 0.1 ether
    uint internal constant EXCHANGE_RATE           = 1000;   // 1 eth = 1000 acre
    uint internal constant PRESALE_DURATION_TIME   = 15;     // 15 days
    uint internal constant CROWDSALE_DURATION_TIME = 21;     // 21 days
    
    // helper
    function getDays(uint _time) internal pure returns(uint) {
        return SafeMath.div(_time, 1 days);
    }
    
    function getHours(uint _time) internal pure returns(uint) {
        return SafeMath.div(_time, 1 hours);
    }
    
    function getMinutes(uint _time) internal pure returns(uint) {
        return SafeMath.div(_time, 1 minutes);
    }
}