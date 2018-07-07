pragma solidity ^0.4.15;

import './zeppelin-solidity/token/ERC20/StandardToken.sol';


/**
* @title CryptolottoToken
* This smart contract is a part of Cryptolotto (cryptolotto.cc) product.
*
* Cryptolotto is a blockchain-based, Ethereum powered lottery which gives to users the most 
* transparent and honest chances of winning.
*
* The main idea of Cryptolotto is straightforward: people from all over the world during the 
* set period of time are contributing an equal amount of ETH to one wallet. When a timer ends 
* this smart-contract powered wallet automatically sends all received ETHs to a one randomly 
* chosen wallet-participant.
*
* Due to the fact that Cryptolotto is built on a blockchain technology, it eliminates any 
* potential for intervention by third parties and gives 100% guarantee of an honest game.
* There are no backdoors and no human or computer soft can interfere the process of picking a winner.
*
* If during the game only one player joins it, then the player will receive all his ETH back.
* If a player sends not the exact amount of ETH - he will receive all his ETH back.
* Creators of the product can change the entrance price for the game. If the price is changed 
* then new rules are applied when a new game starts.
*
* The original idea of Cryptolotto belongs to t.me/crypto_god and t.me/crypto_creator - Founders.
* Cryptolotto smart-contracts are the property of Founders and are protected by copyright,
* trademark, patent, trade secret, other intellectual property, proprietary rights laws and other applicable laws.
*
* All information related to the product can be found only on: 
* - cryptolotto.cc
* - github.com/cryptolotto
* - instagram.com/cryptolotto
* - facebook.com/cryptolotto
*
* Crytolotto was designed and developed by erde.group (t.me/erdegroup).
**/
contract CryptolottoToken is StandardToken {
    /**
    * @dev Token name.
    */
    string public constant name = "Cryptolotto";
    
    /**
    * @dev Token symbol.
    */
    string public constant symbol = "CRY";
    
    /**
    * @dev Amount of decimals.
    */
    uint8 public constant decimals = 18;

    /**
    * @dev Amount of tokens supply.
    */
    uint256 public constant INITIAL_SUPPLY = 100000 * (10 ** uint256(decimals));
 
    /**
    * @dev Token holder struct.
    */
    struct TokenHolder {
        uint balance;
        uint balanceUpdateTime;
        uint rewardWithdrawTime;
    }

    /**
    * @dev Store token holder balances updates time.
    */
    mapping(address => TokenHolder) holders;

    /**
    * @dev Amount of not distributed wei on this dividends period.
    */
    uint256 public weiToDistribute;

    /**
    * @dev Amount of wei that will be distributed on this dividends period.
    */
    uint256 public totalDividends;

    /**
    * @dev Didents period.
    */
    uint256 public period = 2592000;

    /**
    * @dev Store last period start date in timestamp.
    */
    uint256 public lastPeriodStarDate;

    /**
    * @dev Checks tokens balance.
    */
    modifier tokenHolder() {
        require(balanceOf(msg.sender) > 0);
        _;
    }

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    function CryptolottoToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
        lastPeriodStarDate = now - period;
    }

    /**
    * @dev Starts dividends period and allow withdraw dividends.
    */
    function startDividendsPeriod() public {
        require(lastPeriodStarDate + period < now);
        weiToDistribute += address(this).balance - weiToDistribute;
        totalDividends = weiToDistribute;
        lastPeriodStarDate += period;
    }

    /**
    * @dev Transfer coins.
    *
    * @param receiver The address to transfer to.
    * @param amount The amount to be transferred.
    */
    function transfer(address receiver, uint256 amount) public returns (bool) {
        beforeBalanceChanges(msg.sender);
        beforeBalanceChanges(receiver);

        return super.transfer(receiver, amount);
    }

    /**
    * @dev Transfer coins.
    *
    * @param from Address from which will be withdrawn tokens.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transferFrom(address from, address to, uint256 value) 
        public 
        returns (bool) 
    {
        beforeBalanceChanges(from);
        beforeBalanceChanges(to);

        return super.transferFrom(from, to, value);
    }

    /**
    * @dev Fix last balance updates.
    */
    function beforeBalanceChanges(address _who) internal {
        if (holders[_who].balanceUpdateTime <= lastPeriodStarDate) {
            holders[_who].balanceUpdateTime = now;
            holders[_who].balance = balanceOf(_who);
        }
    }

    /**
    * @dev Calculate token holder reward.
    */
    function reward() view public returns (uint) {
        if (holders[msg.sender].rewardWithdrawTime >= lastPeriodStarDate) {
            return 0;
        }
        
        uint256 balance;
        if (holders[msg.sender].balanceUpdateTime <= lastPeriodStarDate) {
            balance = balanceOf(msg.sender);
        } else {
            balance = holders[msg.sender].balance;
        }

        return totalDividends * balance / INITIAL_SUPPLY;
    }

    /**
    * @dev Allow withdraw reward.
    */
    function withdrawReward() public returns (uint) {
        uint value = reward();
        if (value == 0) {
            return 0;
        }
        
        if (!msg.sender.send(value)) {
            return 0;
        }
        
        if (balanceOf(msg.sender) == 0) {
            // garbage collector
            delete holders[msg.sender];
        } else {
            holders[msg.sender].rewardWithdrawTime = now;
        }

        weiToDistribute -= value;

        return value;
    }
    /**
    * @dev Simple payable function that allows accept ether.
    */
    function() public payable {}
}
