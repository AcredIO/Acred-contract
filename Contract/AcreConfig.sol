pragma solidity ^0.4.18;

contract AcreConfig {
    uint internal constant TIME_FACTOR = 1 minutes;

    // Ownable
    uint internal constant OWNERSHIP_DURATION_TIME = 7; // 7 days
    
    // MultiOwnable
    uint8 internal constant MULTI_OWNER_COUNT = 5; // 5 accounts, exclude master
    
    // Lockable
    uint internal constant LOCKUP_DURATION_TIME = 10; // 365 days
    
    // AcreToken
    string internal constant TOKEN_NAME            = "TestAcre";
    string internal constant TOKEN_SYMBOL          = "TestACRE";
    uint8  internal constant TOKEN_DECIMALS        = 18;
    
    uint   internal constant INIT_SUPPLY           = 1*1e8 * 10 ** uint(TOKEN_DECIMALS); // supply
    uint   internal constant CAPITAL_SUPPLY        = 4*1e7 * 10 ** uint(TOKEN_DECIMALS); // supply
    uint   internal constant PRE_PAYMENT_SUPPLY    = 1*1e7 * 10 ** uint(TOKEN_DECIMALS); // supply
    uint   internal constant MAX_MINING_SUPPLY     = 4*1e8 * 10 ** uint(TOKEN_DECIMALS); // supply
    
    // Sale
    uint internal constant MIN_ETHER               = 5*1e17; // 0.5 ether
    uint internal constant EXCHANGE_RATE           = 1000;   // 1 eth = 1000 acre
    uint internal constant PRESALE_DURATION_TIME   = 15;     // 5.8~5.22 
    uint internal constant CROWDSALE_DURATION_TIME = 30;     // 6.11~7.2
    
    // helper
    function getDays(uint _time) internal pure returns(uint) {
        return _time / 1 days;
    }
    
    function getHours(uint _time) internal pure returns(uint) {
        return _time / 1 hours;
    }
    
    function getMinutes(uint _time) internal pure returns(uint) {
        return _time / 1 minutes;
    }
}