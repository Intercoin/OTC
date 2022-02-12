pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TradeRegistratorERC20 is Context {

    using SafeERC20 for IERC20;

    uint256 public lockTime = 2 hours;

    mapping(bytes32 => Trade) public trades;

    enum Status { REGISTERED, CLAIMED, COMPLETED, WITHDRAWN }

    struct Trade {
        address poster;
        address asset;
        uint256 amount;
        address receiver;
        Status status;
        uint256 maxPenalty;
        uint256 deadline;
    }

    event NewTrade(
        address poster,
        address asset,
        uint256 amount,
        address receiver,
        uint256 maxPenalty,
        uint256 deadline
    );


    /**
    * @notice blocks user's money for a certain amount of time and remembers the trade by its hash
    * @param _tradeHash The hash of the trade parameters
    * @param _amount The amount of tokens to be locked
    * @param _tokenAddress The address of the token's smart contract
    * @param _receiverAddress The address of the receiver of the token
    * @param _penaltyAmount The max amount of penalty in the native currency
    */
    function post(
        bytes32 _tradeHash, 
        uint256 _amount, 
        address _tokenAddress, 
        address _receiverAddress, 
        uint256 _penaltyAmount
    ) external {

        require(_tradeHash != bytes32(0), "null trade hash");
        require(_amount > 0, "zero amount");
        require(_tokenAddress != address(0), "zero asset address");
        require(_receiverAddress != address(0), "zero receiver address");

        uint256 lockTime_ = lockTime;

        trades[_tradeHash] = Trade(
            _msgSender(),
            _tokenAddress,
            _amount, 
            _receiverAddress,
            Status.REGISTERED,
            _penaltyAmount,
            block.timestamp + lockTime_
        );

        IERC20(_tokenAddress).safeTransferFrom(_msgSender(), address(this), _amount);


        emit NewTrade(
            _msgSender(),
            _tokenAddress,
            _amount,
            _receiverAddress,
            _penaltyAmount,
            block.timestamp + lockTime_
        );
        
        
    }

    /**
    * @notice register user's request and extends the free withdrawal time
    * @param _tradeHash The hash of the trade
    * @param _signature The signature of the receiver
    */
    function claim(bytes32 _tradeHash, bytes32 _signature) external {

    }

    /**
    * @notice Checks the validity of the provided signatures and give the locked
    * assets to the sender of the transaction, while charging the sender a penalty, if any
    * @param _tradeHash The hash of the trade
    * @param _signatures The array of trade participants's signatures
    */

    function repost(bytes32 _tradeHash, bytes32[] memory _signatures) external {

    }

    /**
    * @notice Returns money to the owner if trade wasn't completed (deadline is passed)
    * @param _tradeHash The hash of the trade
    */

    function withdraw(bytes32 _tradeHash) external {
        Trade memory trade = trades[_tradeHash];
        require(
            trade.status != Status.COMPLETED && 
            trade.status != Status.WITHDRAWN, 
            "invalid trade status"
        );
        require(block.timestamp > trade.deadline, "deadline isn't passed");
        IERC20(trade.asset).safeTransfer(trade.poster, trade.amount);
        trades[_tradeHash].status = Status.WITHDRAWN;
    }

    function calculatePenalty() public {
        
    }
}