pragma solidity ^0.8.11;

contract TradeRegistrator {

    /**
    * @notice blocks user's money for a certain amount of time and remembers the trade by its hash
    * @param _tradeHash The hash of the trade parameters
    * @param _amount The amount of tokens to be locked
    * @param _tokenAddress The address of the token smart contract
    * @param _receiverAddress The address of the receiver of the token
    * @param _penaltyAmount The max amount of penalty in the native currency
    */
    function post(
        bytes32 _tradeHash, 
        uint256 _amount, 
        address _tokenAddress, 
        address _receiverAddress, 
        uint256 _penaltyAmount
    ) public {

    }

    /**
    * @notice register user's request and extends the free withdrawal time
    * @param _tradeHash The hash of the trade
    * @param _signature The signature of the receiver
    */
    function claim(bytes32 _tradeHash, bytes32 _signature) public {

    }

    /**
    * @notice Checks the validity of the provided signatures and give the locked
    * assets to the sender of the transaction, while charging the sender a penalty, if any
    * @param _tradeHash The hash of the trade
    * @param _signatures The array of trade participants's signatures
    */

    function repost(bytes32 _tradeHash, bytes32[] memory _signatures) public {

    }

    function calculatePenalty() public {

    }
}