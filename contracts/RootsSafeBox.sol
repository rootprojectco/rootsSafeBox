pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

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