pragma solidity ^0.8.11;

contract TradeRegistrator {
    function post(
        bytes32 _tradeHash, 
        uint256 _amount, 
        address _tokenAddress, 
        address _receiverAddress, 
        uint256 _penaltyAmount
    ) public {

    }

    function claim(bytes32 _tradeHash, bytes32 _signature) public {

    }

    function repost(bytes32 _tradeHash, bytes32[] memory _signatures) public {
        
    }
}