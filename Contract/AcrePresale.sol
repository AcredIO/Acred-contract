pragma solidity ^0.4.18;

import "./AcreSale.sol";

contract AcrePresale is AcreSale {
    function AcrePresale(
        address _sendEther,
        uint _softCapToken,
        uint _hardCapToken,
        AcreToken _addressOfTokenUsedAsReward
    ) AcreSale(
        _sendEther,
        _softCapToken, 
        _hardCapToken, 
        _addressOfTokenUsedAsReward) public {
    }
    
    function startPresale() onlyOwnersWithMaster public {
        startSale(PRESALE_DURATION_TIME);
    }
    
    function getBonusRate() public constant returns(uint8 bonusRate) {
        if      (now <= startSaleTime + (8*TIME_FACTOR))  { bonusRate = 30; } // 5.8~5.15, 8days  
        else if (now <= startSaleTime + (15*TIME_FACTOR)) { bonusRate = 25; } // 5.16~5.22, 7days
        else                                              { bonusRate = 0; }  // 
    } 
}