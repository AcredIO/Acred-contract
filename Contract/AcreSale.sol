pragma solidity 0.4.20;

import "./AcreToken.sol";

contract AcreSale is MultiOwnable {
    uint public saleDeadline;
    uint public startSaleTime;
    uint public softCapToken;
    uint public hardCapToken;
    uint public soldToken;
    uint public receivedEther;
    address public sendEther;
    AcreToken public tokenReward;
    bool public fundingGoalReached = false;
    bool public saleOpened = false;
    
    Payment public kyc;
    Payment public refund;
    Payment public withdrawal;

    mapping(uint=>address) public indexedFunders;
    mapping(address => Order) public orders;
    uint public funderCount;
    
    event logStartSale(uint softCapToken, uint hardCapToken, uint minEther, uint exchangeRate, uint startTime, uint deadline);
    event logReservedToken(address indexed funder, uint amount, uint token, uint bonusRate);
    event logWithdrawFunder(address indexed funder, uint value);
    event logWithdrawContractToken(address indexed owner, uint value);
    event logCheckGoalReached(uint raisedAmount, uint raisedToken, bool reached);
    event logCheckOrderstate(address indexed funder, eOrderstate oldState, eOrderstate newState);
    
    enum eOrderstate { NONE, KYC, REFUND }
    
    struct Order {
        eOrderstate state;
        uint paymentEther;
        uint reservedToken;
        bool withdrawn;
    }
    
    struct Payment {
        uint token;
        uint eth;
        uint count;
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
        require(_sendEther != address(0));
        require(_addressOfTokenUsedAsReward != address(0));
        require(_softCapToken > 0 && _softCapToken <= _hardCapToken);
        sendEther = _sendEther;
        softCapToken = _softCapToken * 10 ** uint(TOKEN_DECIMALS);
        hardCapToken = _hardCapToken * 10 ** uint(TOKEN_DECIMALS);
        tokenReward = AcreToken(_addressOfTokenUsedAsReward);
    }
    
    function startSale(uint _durationTime) onlyManagers internal {
        require(softCapToken > 0 && softCapToken <= hardCapToken);
        require(hardCapToken > 0 && hardCapToken <= tokenReward.balanceOf(this));
        require(_durationTime > 0);
        require(startSaleTime == 0);

        startSaleTime = now;
        saleDeadline = SafeMath.add(startSaleTime, SafeMath.mul(_durationTime, TIME_FACTOR));
        saleOpened = true;
        
        logStartSale(softCapToken, hardCapToken, MIN_ETHER, EXCHANGE_RATE, startSaleTime, saleDeadline);
    }
    
    // get
    function getRemainingSellingTime() public constant returns(uint remainingTime) {
        if(now <= saleDeadline) {
            remainingTime = getMinutes(SafeMath.sub(saleDeadline, now));
        }
    }
    
    function getRemainingSellingToken() public constant returns(uint remainingToken) {
        remainingToken = SafeMath.sub(hardCapToken, soldToken);
    }
    
    function getReachedSoftcap() public constant returns(bool reachedSoftcap) {
        reachedSoftcap = soldToken >= softCapToken;
    }
    
    function getContractBalanceOf() public constant returns(uint blance) {
        blance = tokenReward.balanceOf(this);
    }
    
    function getCurrentBonusRate() public constant returns(uint8 bonusRate);
    
    // check
    function checkGoalReached() onlyManagers afterSaleDeadline public {
        if(saleOpened) {
            if(getReachedSoftcap()) {
                fundingGoalReached = true;
            }
            saleOpened = false;
            logCheckGoalReached(receivedEther, soldToken, fundingGoalReached);
        }
    }
    
    function checkKYC(address _funder) onlyManagers afterSaleDeadline public {
        require(!saleOpened);
        require(orders[_funder].reservedToken > 0);
        require(orders[_funder].state != eOrderstate.KYC);
        require(!orders[_funder].withdrawn);
        
        eOrderstate oldState = orders[_funder].state;
        
        // old, decrease
        if(oldState == eOrderstate.REFUND) {
            refund.token = refund.token.sub(orders[_funder].reservedToken);
            refund.eth   = refund.eth.sub(orders[_funder].paymentEther);
            refund.count = refund.count.sub(1);
        }
        
        // state
        orders[_funder].state = eOrderstate.KYC;
        kyc.token = kyc.token.add(orders[_funder].reservedToken);
        kyc.eth   = kyc.eth.add(orders[_funder].paymentEther);
        kyc.count = kyc.count.add(1);
        logCheckOrderstate(_funder, oldState, eOrderstate.KYC);
    }
    
    function checkRefund(address _funder) onlyManagers afterSaleDeadline public {
        require(!saleOpened);
        require(orders[_funder].reservedToken > 0);
        require(orders[_funder].state != eOrderstate.REFUND);
        require(!orders[_funder].withdrawn);
        
        eOrderstate oldState = orders[_funder].state;
        
        // old, decrease
        if(oldState == eOrderstate.KYC) {
            kyc.token = kyc.token.sub(orders[_funder].reservedToken);
            kyc.eth   = kyc.eth.sub(orders[_funder].paymentEther);
            kyc.count = kyc.count.sub(1);
        }
        
        // state
        orders[_funder].state = eOrderstate.REFUND;
        refund.token = refund.token.add(orders[_funder].reservedToken);
        refund.eth   = refund.eth.add(orders[_funder].paymentEther);
        refund.count = refund.count.add(1);
        logCheckOrderstate(_funder, oldState, eOrderstate.REFUND);
    }
    
    // withdraw
    function withdrawFunder(address _funder) onlyManagers afterSaleDeadline public {
        require(!saleOpened);
        require(fundingGoalReached);
        require(orders[_funder].reservedToken > 0);
        require(orders[_funder].state == eOrderstate.KYC);
        require(!orders[_funder].withdrawn);
        
        // token
        tokenReward.transfer(_funder, orders[_funder].reservedToken);
        withdrawal.token = withdrawal.token.add(orders[_funder].reservedToken);
        withdrawal.eth   = withdrawal.eth.add(orders[_funder].paymentEther);
        withdrawal.count = withdrawal.count.add(1);
        orders[_funder].withdrawn = true;
        logWithdrawFunder(_funder, orders[_funder].reservedToken);
    }
    
    function withdrawContractToken(uint _value) onlyManagers public {
        tokenReward.transfer(msg.sender, _value);
        logWithdrawContractToken(msg.sender, _value);
    }
    
    // payable
    function () payable public {
        require(saleOpened);
        require(now <= saleDeadline);
        require(MIN_ETHER <= msg.value);
        
        uint amount = msg.value;
        uint curBonusRate = getCurrentBonusRate();
        uint token = (amount.mul(curBonusRate.add(100)).div(100)).mul(EXCHANGE_RATE);
        
        require(token > 0);
        require(SafeMath.add(soldToken, token) <= hardCapToken);
        
        sendEther.transfer(amount);
        
        // funder info
        if(orders[msg.sender].paymentEther == 0) {
            indexedFunders[funderCount] = msg.sender;
            funderCount = funderCount.add(1);
            orders[msg.sender].state = eOrderstate.NONE;
        }
        
        orders[msg.sender].paymentEther = orders[msg.sender].paymentEther.add(amount);
        orders[msg.sender].reservedToken = orders[msg.sender].reservedToken.add(token);
        receivedEther = receivedEther.add(amount);
        soldToken = soldToken.add(token);
        
        logReservedToken(msg.sender, amount, token, curBonusRate);
    }
}
