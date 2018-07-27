pragma solidity ^0.4.21;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./RootsSafeBox.sol";

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

        boxes[newContract].addr = newContract;
        boxes[newContract].owner = msg.sender;
        boxes[newContract].destination = _destinationAddress;
        boxes[newContract].index = boxesAddr.push(newContract) - 1;

        return newContract;
    }
}
