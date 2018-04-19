pragma solidity ^0.4.18;

import "./AcreToken.sol";

contract AcreSale is Ownable {
    using SafeMath for uint;
    
    uint public deadline;
    uint public startTime;
    uint public softCapToken;
    uint public hardCapToken;
    uint public receivedEther;
    uint public soldToken;
    address public sendEther;
    AcreToken public tokenReward;
    bool public fundingGoalReached = false;
    bool public saleOpened = false;
    
    mapping(uint=>address) public indexedFunders;
    mapping(address => Property) public fundersProperty;
    uint public funderCount = 0;
    
    event logStart(uint softCapToken, uint hardCapToken, uint minEther, uint exchangeRate, uint startTime, uint deadline);
    event logReservedToken(address indexed backer, uint amount, uint token, uint bonusRate);
    event logWithdrawalToken(address indexed addr, uint amount, bool result, bool owner);
    event logWithdrawalEther(address indexed addr, uint amount, bool result, bool owner);
    event logCheckGoalReached(uint raisedAmount, uint raisedToken, bool reached);
    event logCheckFunderKYC(address indexed backer, bool isKYC);
    
    struct Property {
        uint paymentEther;
        uint reservedToken;
        bool withdrawed;
        bool isKYC;
    }
    
    modifier afterDeadline { 
        require(now >= deadline); 
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
    
    function start(uint _durationTime) onlyOwner public {
        require(sendEther != address(0));
        require(softCapToken > 0 && softCapToken <= hardCapToken);
        require(hardCapToken > 0 && hardCapToken <= tokenReward.balanceOf(this));
        require(_durationTime > 0);
        require(startTime == 0);

        startTime = now;
        deadline = startTime + (_durationTime * TIME_FACTOR);
        saleOpened = true;
        
        logStart(softCapToken, hardCapToken, MIN_ETHER, EXCHANGE_RATE, startTime, deadline);
    }
    
    // get
    function getRemainingTime() public constant returns(uint remainTime) {
        if(now < deadline) {
            remainTime = (deadline - now) / (1 minutes);
        }
    }
    
    function getRemainingToken() public constant returns(uint remainToken) {
        remainToken = hardCapToken - soldToken;
    }
    
    function getContractBalance() public constant returns(uint blance) {
        blance = tokenReward.balanceOf(this);
    }
    
    function getBonusRate() public constant returns(uint8 bonusRate);
    
    // check
    function checkGoalReached() onlyOwner afterDeadline public {
        if(saleOpened) {
            if(soldToken >= softCapToken) {
                fundingGoalReached = true;
            }
            saleOpened = false;
            logCheckGoalReached(receivedEther, soldToken, fundingGoalReached);
        }
    }
    
    function checkFunderKYC(address _backer, bool _isKYC) onlyOwner public {
        require(fundersProperty[_backer].isKYC != _isKYC);
        fundersProperty[_backer].isKYC = _isKYC;
        logCheckFunderKYC(_backer, _isKYC);
    }
    
    // withdrawal
    function withdrawalOwner() onlyOwner afterDeadline public {
        require(!saleOpened);
        
        if(fundingGoalReached) {
            require(softCapToken-soldToken > 0);
            uint val = softCapToken-soldToken;
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
    
    function withdrawalFunder(address _backer) onlyOwner afterDeadline public {
        require(!saleOpened);
        require(!fundersProperty[_backer].withdrawed);
            
        if(fundingGoalReached) {
            // token    
            require(fundersProperty[_backer].reservedToken > 0);
            require(fundersProperty[_backer].isKYC);
            tokenReward.transfer(_backer, fundersProperty[_backer].reservedToken);
            fundersProperty[_backer].withdrawed = true;
            logWithdrawalToken(
                _backer, 
                fundersProperty[_backer].reservedToken,
                fundersProperty[_backer].withdrawed,
                false);
        }
    }
    
    function withdrawalToken(uint _value) onlyOwner public {
        tokenReward.transfer(msg.sender, _value);
        logWithdrawalToken(msg.sender, _value, true, true);
    }
    
    function withdrawalEther(uint _amount) onlyOwner public {
        require(address(this).balance >= _amount);
        msg.sender.transfer(_amount);
        logWithdrawalEther(msg.sender, _amount, true, true);
    }
    
    // payable
    function () payable public {
        require(saleOpened);
        require(now <= deadline);
        require(MIN_ETHER <= msg.value);
        
        uint amount = msg.value;
        uint bonusRate = getBonusRate();
        uint token = (amount.mul(bonusRate.add(100)).div(100)).mul(EXCHANGE_RATE);
        
        require(token > 0);
        require(soldToken + token <= hardCapToken);
        
        sendEther.transfer(amount);
        
        // funder info
        if(fundersProperty[msg.sender].paymentEther == 0) {
            indexedFunders[funderCount] = msg.sender;
            funderCount++;
        }
        
        fundersProperty[msg.sender].paymentEther = fundersProperty[msg.sender].paymentEther.add(amount);
        fundersProperty[msg.sender].reservedToken = fundersProperty[msg.sender].reservedToken.add(token);
        receivedEther = receivedEther.add(amount);
        soldToken = soldToken.add(token);
        
        logReservedToken(msg.sender, amount, token, bonusRate);
    }
}
