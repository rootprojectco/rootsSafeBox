pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

// This is Safe Box for RootsProject.co

contract RootsSafeBox is Ownable {

	// address who receive all assets from this smart contract
	address public destinationAddress;

	// timestamp until assets is frozen at this smart contract
	uint256 public safeTime;

	/**
	* @dev Reverts if a safe box is still locked.
	*/
	modifier onlyAfterSafeTime {
		require(now >= safeTime);
		_;
	}

	// constructor
	function RootsSafeBox(address _destinationAddress, uint256 _safeTime) public {
		require(_destinationAddress != 0x0);
		require(_safeTime > now);

		destinationAddress = _destinationAddress;
		safeTime = _safeTime;
	}

	function changeSafeTime(uint256 _safeTime) onlyOwner public returns (bool) {
		require(_safeTime > now);
		safeTime = _safeTime;
		return true;
	}

	/**
    * Claim withdraw tokens.
    */
	function withdrawToken(address _tokenAddress) onlyAfterSafeTime public {
		require(_tokenAddress != 0x0);
		return this.baseWithdrawToken(_tokenAddress);
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
		require(ERC20(_tokenAddress).balanceOf(address(this)) > 0);
		ERC20(_tokenAddress).transfer(destinationAddress, ERC20(_tokenAddress).balanceOf(address(this)));
	}

	/**
	* @dev Standard ERC223 function that will handle incoming token transfers.
	*
	* @param _from  Token sender address.
	* @param _value Amount of tokens.
	* @param _data  Transaction metadata.
	*/
	function tokenFallback(address _from, uint _value, bytes _data) external returns (bool) {
		return true;
	}
}
