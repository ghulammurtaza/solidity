/**
 * The Scalify token contract bases on the ERC20 standard token contracts from
 * zeppelin and is extended by functions to issue tokens as needed by the
 * Scalify ICO.
 * authors: ghulam murtaza
 * */

pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
        assert(token.transfer(to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        assert(token.transferFrom(from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        assert(token.approve(spender, value));
    }
}

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
    using SafeERC20 for ERC20Basic;

    // ERC20 basic token contract being held
    ERC20Basic public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint64 public releaseTime;

    function TokenTimelock(ERC20Basic _token, address _beneficiary, uint64 _releaseTime) public {
        require(_releaseTime > uint64(block.timestamp));
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        require(uint64(block.timestamp) >= releaseTime);

        uint256 amount = token.balanceOf(this);
        require(amount > 0);

        token.safeTransfer(beneficiary, amount);
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Owned() public {
        owner = msg.sender;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract Scalifyt5Token is StandardToken, Owned {
  string public constant name = "Scalifyt5Token";
  string public constant symbol = "STT5";
  uint8 public constant decimals = 18;
  uint256 public totalSold = 0;
  bool public tokenSaleClosed = false;

  /// 75% Maximum tokens to be allocated on the sale
  uint256 public constant TOKENS_SALE_HARD_CAP = 750000000000000000000000; // 750000*10**18

  /// Base exchange rate is set to 1 ETH = 100 STT2.
  uint256 public constant BASE_RATE = 100;

  /// seconds since 01.01.1970 to 12.03.2018 (18:00:00 o'clock UTC)
  /// HOT sale start time
  uint64 public constant dateCloseGroup = 1520953805 + 5 minutes;

  //seconds since 01.01.1970 to 14.03.2018 (18:00:00 o'clock UTC)
  // closeGroup ends and Pre ICO start time 14.03.2018
  uint64 public constant datePreIcoSale = 1520954105 + 5 minutes;

  // closeGroup ends and Pre ICO start time 16.03.2018 (18:00:00 o'clock UTC)
  uint64 public constant dateIcoSale = 1520954405 + 5 minutes;

  address private devsToken = 0xaa1ac57fb5dd8a5474675e0e930b7ac6d9d9f198;
  address private legalToken = 0x022ace3bdd04972fb0fd85a16bf433a37abf78c0;
  address private mgtToken = 0xd3a33fc1ad3e52d6a23f0c2d432dda9f77f67c14;
  address private marktToken = 0x24d88dc6720380eedc1320d4669a75d420c7efce;
  address private researchToken = 0xbb98db886fc3993eaa24996bf84e2fe5176e6189;

  /// token caps for each round
  uint256[3] private roundCaps = [
      225000000000000000000000, // closegroup sale  (750000000000000000000000*.30)
      225000000000000000000000, // PreIco Sale   (750000000000000000000000*.30)
      300000000000000000000000 // ICO Sale   (750000000000000000000000*.40)
  ];

  uint8[3] private roundDiscountPercentages = [50, 15, 0];

  modifier inProgress {
      require(totalSold < TOKENS_SALE_HARD_CAP
          && !tokenSaleClosed && now >= dateCloseGroup);
      _;
  }

  /// Allow the closing to happen only once
  modifier beforeEnd {
      require(!tokenSaleClosed);
      _;
  }

  /// Require that the token sale has been closed
  modifier tradingOpen {
      require(tokenSaleClosed);
      _;
  }

  function Scalifyt5Token() public {
    totalSupply = 1000000000000000000000000;

    //assign initial tokens for sale to contracter
     balances[msg.sender] = 750000000000000000000000;

    //5% for each dev, legal, management, marketing and research
    balances[devsToken] = 50000000000000000000000;
    //balances(legalToken, 50000000000000000000000);
    //balances(mgtToken, 50000000000000000000000);
    //balances(marktToken, 50000000000000000000000);
    //balances(researchToken, 50000000000000000000000);
  }

  /// @dev This default function allows token to be purchased by directly
  /// sending ether to this smart contract.
  function () public payable {
      purchaseTokens(msg.sender);
  }

  /// @dev Issue token based on Ether received.
  /// @param _beneficiary Address that newly issued token will be sent to.
  function purchaseTokens(address _beneficiary) public payable {
      // only accept a minimum amount of ETH?
      require(msg.value >= 0.01 ether);

      uint256 tokens = computeTokenAmount(msg.value);

      // roll back if hard cap reached
      require(totalSold.add(tokens) <= TOKENS_SALE_HARD_CAP);

      issueTokens(_beneficiary, tokens);

      /// forward the raised funds to the contract creator
      owner.transfer(this.balance);
  }

  /// @dev issue tokens for a single buyer
  /// @param _beneficiary addresses that the tokens will be sent to.
  /// @param _tokens the amount of tokens, with decimals expanded (full).
  function issueTokens(address _beneficiary, uint256 _tokens) internal {
      require(_beneficiary != address(0));

      // increase total sold count
      totalSold = totalSold.add(_tokens);
      // update the beneficiary balance to number of tokens sent
      balances[_beneficiary] = balances[_beneficiary].add(_tokens);

      // event is fired when tokens issued
      Transfer(address(0), _beneficiary, _tokens);
  }

  /// @dev Returns the current price.
  function price() public view returns (uint256 tokens) {
      return computeTokenAmount(1 ether);
  }

  /// @dev Compute the amount of DOR token that can be purchased.
  /// @param ethAmount Amount of Ether in WEI to purchase DOR.
  /// @return Amount of token to purchase
  function computeTokenAmount(uint256 ethAmount) internal view returns (uint256 tokens) {
      uint256 tokenBase = ethAmount.mul(BASE_RATE);
      uint8 roundNum = currentRoundIndex();
      tokens = tokenBase.mul(100)/(100 - (roundDiscountPercentages[roundNum]));
      while(tokens.add(totalSold) > roundCaps[roundNum] && roundNum < 2){
         roundNum++;
         tokens = tokenBase.mul(100)/(100 - (roundDiscountPercentages[roundNum]));
      }
  }

  /// @dev Determine the current sale round
  /// @return integer representing the index of the current sale round
  function currentRoundIndex() internal view returns (uint8 roundNum) {
      roundNum = currentRoundIndexByDate();

      /// round determined by conjunction of both time and total sold tokens
      while(roundNum < 2 && totalSold > roundCaps[roundNum]) {
          roundNum++;
      }
  }

  /// @dev Determine the current sale tier.
  /// @return the index of the current sale tier by date.
  function currentRoundIndexByDate() internal view returns (uint8 roundNum) {
    require(now >= dateCloseGroup);
    if(now > dateIcoSale) return 2;
    if(now > datePreIcoSale) return 1;
    if(now > dateCloseGroup) return 0;
  }

  /// @dev Closes the sale burns the unsold
  function close() public onlyOwner beforeEnd {
      /// burn the unallocated tokens
      uint256 _unSold = totalSupply.sub(totalSold);
      balances[msg.sender] = balances[msg.sender].sub(_unSold);
      totalSupply = totalSupply.sub(_unSold);

      //no more tokens can be issued after this line
      tokenSaleClosed = true;

      /// forward the raised funds to the contract creator
      owner.transfer(this.balance);
  }


  /// Transfer limited by the tradingOpen modifier
  function transferFrom(address _from, address _to, uint256 _value) public tradingOpen returns (bool) {
      return super.transferFrom(_from, _to, _value);
  }

  /// Transfer limited by the tradingOpen modifier
  function transfer(address _to, uint256 _value) public tradingOpen returns (bool) {
      return super.transfer(_to, _value);
  }
}
