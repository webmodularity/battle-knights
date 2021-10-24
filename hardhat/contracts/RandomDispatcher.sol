//SPDX-License-Identifier: None
pragma solidity ^0.8.5;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRandomDispatcher.sol";
import "./IKnight.sol";

contract RandomDispatcher is IRandomDispatcher, Ownable, VRFConsumerBase {
    address private knightContractAddress;
    // VRF Request mapping to DispatchRequest
    mapping(bytes32 => IRandomDispatcher.DispatchRequest) private randomRequestToDispatchRequest;
    uint vrfFee;
    bytes32 vrfKeyHash;
    // Events
    event RequestedRandomness(bytes32 requestId);

    modifier onlyKnightContracts {
        require(msg.sender == knightContractAddress, "Only calls from knightContract allowed!");
        _;
    }

    constructor(
        address _knightContractAddress,
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint _fee
    ) VRFConsumerBase(_vrfCoordinator, _link) {
        knightContractAddress = _knightContractAddress;
        vrfKeyHash = _keyHash;
        vrfFee = _fee;
    }

    function requestRandomNumber(IRandomDispatcher.Destination dest, uint id) external override onlyKnightContracts {
        require(LINK.balanceOf(address(this)) >= vrfFee, "Not enough LINK");
        bytes32 randomRequestId = requestRandomness(vrfKeyHash, vrfFee);
        emit RequestedRandomness(randomRequestId);
        randomRequestToDispatchRequest[randomRequestId] = IRandomDispatcher.DispatchRequest(dest, id);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        IRandomDispatcher.DispatchRequest memory dispatchRequest = randomRequestToDispatchRequest[requestId];
        if (dispatchRequest.id > 0) {
            if (dispatchRequest.dest == IRandomDispatcher.Destination.Knight) {
                IKnight knightContract = IKnight(knightContractAddress);
                knightContract.useRandomNumber(randomness, dispatchRequest.id);
            }
            // GC request
            delete randomRequestToDispatchRequest[requestId];
        }
    }

}