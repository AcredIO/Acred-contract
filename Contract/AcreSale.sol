pragma solidity ^0.4.18;

import "./AcreToken.sol";

contract AcreSale is MultiOwnable {
    using SafeMath for uint;
    
    uint public saleDeadline;
    uint public startSaleTime;
    uint public softCapToken;
    uint public hardCapToken;
    uint public receivedEther;
    uint public soldToken;
    address public sendEther;
    AcreToken public tokenReward;
    bool public fundingGoalReached = false;
    bool public saleOpened = false;
    
    mapping(uint=>address) public indexedFunders;
    mapping(address => Order) public orders;
    uint public funderCount = 0;
    
    event logStart(uint softCapToken, uint hardCapToken, uint minEther, uint exchangeRate, uint startTime, uint deadline);
    event logReservedToken(address indexed backer, uint amount, uint token, uint bonusRate);
    event logWithdrawalToken(address indexed addr, uint amount, bool result, bool owner);
    event logWithdrawalEther(address indexed addr, uint amount, bool result, bool owner);
    event logCheckGoalReached(uint raisedAmount, uint raisedToken, bool reached);
    event logCheckFunderKYC(address indexed backer, bool isKYC);
    
    struct Order {
        uint paymentEther;
        uint reservedToken;
        bool withdrawed;
        bool isKYC;
    }
    
    modifier afterSaleDeadline { 
        require(now > saleDeadline); 
        _; 
    }
    
    function AcreSale(
        address _sendEther,
        uint _softCapToken,
        uint _hardCapToken,
        AcreToken _addressOfTokenUsedAsReward
    ) public {
        sendEther = _sendEther;
        softCapToken = _softCapToken * 10 ** uint(TOKEN_DECIMALS);
        hardCapToken = _hardCapToken * 10 ** uint(TOKEN_DECIMALS);
        tokenReward = AcreToken(_addressOfTokenUsedAsReward);
    }
    
    function startSale(uint _durationTime) onlyOwners public {
        require(sendEther != address(0));
        require(softCapToken > 0 && softCapToken <= hardCapToken);
        require(hardCapToken > 0 && hardCapToken <= tokenReward.balanceOf(this));
        require(_durationTime > 0);
        require(startSaleTime == 0);

        startSaleTime = now;
        saleDeadline = startSaleTime + (_durationTime * TIME_FACTOR);
        saleOpened = true;
        
        logStart(softCapToken, hardCapToken, MIN_ETHER, EXCHANGE_RATE, startSaleTime, saleDeadline);
    }
    
    // get
    function getRemainingSellingTime() public constant returns(uint remainingTime) {
        if(now <= saleDeadline) {
            remainingTime = getRemainingTime((saleDeadline - now));
        }
    }
    
    function getRemainingSellingToken() public constant returns(uint remainingToken) {
        remainingToken = hardCapToken - soldToken;
    }
    
    function getContractBalance() public constant returns(uint blance) {
        blance = tokenReward.balanceOf(this);
    }
    
    function getBonusRate() public constant returns(uint8 bonusRate);
    
    // check
    function checkGoalReached() onlyOwners afterSaleDeadline public {
        if(saleOpened) {
            if(soldToken >= softCapToken) {
                fundingGoalReached = true;
            }
            saleOpened = false;
            logCheckGoalReached(receivedEther, soldToken, fundingGoalReached);
        }
    }
    
    function checkFunderKYC(address _backer, bool _isKYC) onlyOwners public {
        require(orders[_backer].isKYC != _isKYC);
        orders[_backer].isKYC = _isKYC;
        logCheckFunderKYC(_backer, _isKYC);
    }
    
    // withdrawal
    function withdrawalOwner() onlyOwners afterSaleDeadline public {
        require(!saleOpened);
        
        if(fundingGoalReached) {
            require(hardCapToken-soldToken > 0);
            uint val = hardCapToken-soldToken;
            tokenReward.transfer(msg.sender, val);
            logWithdrawalToken(msg.sender, val, true, true);
        }
        else {
            require(tokenReward.balanceOf(this) > 0);
            uint val2 = tokenReward.balanceOf(this);
            tokenReward.transfer(msg.sender, val2);
            logWithdrawalToken(msg.sender, val2, true, true);
        }
    }
    
    function withdrawalFunder(address _backer) onlyOwners afterSaleDeadline public {
        require(!saleOpened);
        require(!orders[_backer].withdrawed);
            
        if(fundingGoalReached) {
            // token    
            require(orders[_backer].reservedToken > 0);
            require(orders[_backer].isKYC);
            tokenReward.transfer(_backer, orders[_backer].reservedToken);
            orders[_backer].withdrawed = true;
            logWithdrawalToken(
                _backer, 
                orders[_backer].reservedToken,
                orders[_backer].withdrawed,
                false);
        }
    }
    
    function withdrawalFunderFromIndex(uint _Index) onlyOwners afterSaleDeadline public {
        withdrawalFunder(indexedFunders[_Index]);
    }
    
    function withdrawalToken(uint _value) onlyOwners public {
        tokenReward.transfer(msg.sender, _value);
        logWithdrawalToken(msg.sender, _value, true, true);
    }
    
    // payable
    function () payable public {
        require(saleOpened);
        require(now <= saleDeadline);
        require(MIN_ETHER <= msg.value);
        
        uint amount = msg.value;
        uint bonusRate = getBonusRate();
        uint token = (amount.mul(bonusRate.add(100)).div(100)).mul(EXCHANGE_RATE);
        
        require(token > 0);
        require(soldToken + token <= hardCapToken);
        
        sendEther.transfer(amount);
        
        // funder info
        if(orders[msg.sender].paymentEther == 0) {
            indexedFunders[funderCount] = msg.sender;
            funderCount++;
        }
        
        orders[msg.sender].paymentEther = orders[msg.sender].paymentEther.add(amount);
        orders[msg.sender].reservedToken = orders[msg.sender].reservedToken.add(token);
        receivedEther = receivedEther.add(amount);
        soldToken = soldToken.add(token);
        
        logReservedToken(msg.sender, amount, token, bonusRate);
    }
}
