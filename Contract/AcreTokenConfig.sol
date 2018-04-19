pragma solidity ^0.4.18;

contract AcreTokenConfig {
    uint internal constant TIME_FACTOR = 1 minutes;

    // Ownable
    uint internal constant OWNERSHIP_DURATION_TIME = 1;
    
    // MultiOwnable
    uint8 internal constant MULTI_OWNER_COUNT = 5;
    
    // AcreToken
    string internal constant TOKEN_NAME         = "TestAcre";
    string internal constant TOKEN_SYMBOL       = "TestACRE";
    uint8  internal constant TOKEN_DECIMALS     = 18;
    uint   internal constant INIT_SUPPLY        = 4*1e8;
    uint   internal constant CAPITAL_SUPPLY     = 4*1e8;
    uint8  internal constant PRE_MINTED_PERCENT = 30;
    
    // Sale
    uint internal constant MIN_ETHER     = 5*1e17; // 0.5 ether
    uint internal constant EXCHANGE_RATE = 5000;   // 1 eth = 5000 acre
}