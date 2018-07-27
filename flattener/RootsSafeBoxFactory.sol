pragma solidity ^0.4.24;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts/RootsSafeBox.sol

// This is Safe Box for RootsProject.co

contract RootsSafeBox is Ownable {
    using SafeMath for uint256;

    // address who receive all assets from this smart contract
    address public destinationAddress;

    // address for default token smart contract
    address public defaultTokenAddress;

    // timestamp until assets is frozen at this smart contract
    uint256 public safeTime;

    // how much ERC223 tokens store at this SafeBox (at this smart contract)
    mapping (address => uint256) public balances;

    /**
    * @dev Reverts if a safe box is still locked.
    */
    modifier onlyAfterSafeTime {
        require(now >= safeTime);
        _;
    }

    // constructor
    function RootsSafeBox(address _destinationAddress, address _defaultTokenAddress, uint256 _safeTime, address _owner) public {
        require(_destinationAddress != 0x0);
        require(_defaultTokenAddress != 0x0);
        require(_owner != 0x0);
        require(_safeTime > now);

        destinationAddress = _destinationAddress;
        defaultTokenAddress = _defaultTokenAddress;
        safeTime = _safeTime;
        owner = _owner;
    }

    function changeSafeTime(uint256 _safeTime) onlyOwner public returns (bool) {
        require(_safeTime > now);
        safeTime = _safeTime;
        return true;
    }

    /**
    * Claim withdraw default tokens.
    */
    function withdrawToken() onlyAfterSafeTime public {
        return baseWithdrawToken(defaultTokenAddress);
    }

    /**
    * Claim withdraw tokens.
    */
    function withdrawToken(address _tokenAddress) onlyAfterSafeTime public {
        require(_tokenAddress != 0x0);
        return baseWithdrawToken(_tokenAddress);
    }

    /**
    * Claim withdraw eth.
    */
    function withdrawEth() onlyAfterSafeTime public {
        require(address(this).balance > 0);
        destinationAddress.transfer(address(this).balance);
    }

    /**
    * Base function for withdraw tokens.
    */
    function baseWithdrawToken(address _tokenAddress) internal {
        uint256 balance = ERC20(_tokenAddress).balanceOf(address(this));
        require(balance > 0);

        ERC20(_tokenAddress).transfer(destinationAddress, balance);

        balances[_tokenAddress] = 0;
    }

    /**
    * @dev Standard ERC223 function that will handle incoming token transfers.
    *
    * @param _from  Token sender address.
    * @param _value Amount of tokens.
    * @param _data  Transaction metadata.
    */
    function tokenFallback(address _from, uint _value, bytes _data) external returns (bool) {
        balances[msg.sender] = balances[msg.sender].add(_value);
        return true;
    }
}

// File: contracts/RootsSafeBoxFactory.sol

contract RootsSafeBoxFactory is Ownable {

    using SafeMath for uint256;

    struct SafeBox {
        address addr;
        address owner;
        address destination;
        uint256 index;
    }

    // address of Roots token
    address public tokenAddress;

    // ---====== SAFE BOXES ======---
    /**
     * @dev Get safebox object by address
     */
    mapping(address => SafeBox) public boxes;

    /**
     * @dev Contracts addresses list
     */
    address[] public boxesAddr;

    /**
     * @dev Count of contracts in list
     */
    function numBoxes() public view returns (uint256)
    { return boxesAddr.length; }

    // ---====== CONSTRUCTOR ======---

    function RootsSafeBoxFactory(address _rootsToken) public {
        tokenAddress = _rootsToken;
    }

    function create(address _destinationAddress, uint256 _safeTime) public returns (RootsSafeBox) {
        RootsSafeBox newContract = new RootsSafeBox(_destinationAddress, tokenAddress, _safeTime, msg.sender);

        boxes[_address].addr = address(newContract);
        boxes[_address].owner = msg.sender;
        boxes[_address].destination = _destinationAddress;
        boxes[_address].index = boxesAddr.push(address(newContract)) - 1;

        return newContract;
    }
}
