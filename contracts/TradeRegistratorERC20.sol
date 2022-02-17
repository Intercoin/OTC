pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";


contract TradeRegistratorERC20 is Context {

    using SafeERC20 for IERC20;

    uint256 public lockTime = 2 hours;

    mapping(bytes32 => TransferInfo) public transfers;

    enum Status { NONEXIST, REGISTERED, PUBLISHED, COMPLETED, WITHDRAWN }

    struct TransferInfo {
        address poster;
        address asset;
        uint256 amount;
        address receiver;
        Status status;
        uint256 maxPenalty;
        uint256 deadline;
        bytes[] signatures;
        uint256 withdrawPenalty;
    }

    event NewTransfer(
        address poster,
        address asset,
        uint256 amount,
        address receiver,
        uint256 maxPenalty,
        uint256 deadline
    );

    /**
    * @notice Returns registered signatures
    * @param _tradeHash The hash of the trade parameters
    * @param _index The index of the signature
    */
    function getSignature(bytes32 _tradeHash, uint256 _index) external view returns(bytes memory){
        return transfers[_tradeHash].signatures[_index];
    }

    /**
    * @notice blocks user's money for a certain amount of time and remembers the trade by its hash
    * @param _tradeHash The hash of the trade parameters
    * @param _amount The amount of tokens to be locked
    * @param _tokenAddress The address of the token's smart contract
    * @param _receiverAddress The address of the receiver of the token
    * @param _penaltyAmount The max amount of penalty in the native currency
    */

    function lock(
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
        require(transfers[_tradeHash].status == Status.NONEXIST, "trade already exists");

        uint256 lockTime_ = lockTime;
        bytes[] memory emptyArray;

        transfers[_tradeHash] = TransferInfo(
            _msgSender(),
            _tokenAddress,
            _amount, 
            _receiverAddress,
            Status.REGISTERED,
            _penaltyAmount,
            block.timestamp + lockTime_,
            emptyArray,
            0
        );

        IERC20(_tokenAddress).safeTransferFrom(_msgSender(), address(this), _amount);


        emit NewTransfer(
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
    function publish(bytes32 _tradeHash, bytes memory _signature) external {
        TransferInfo memory transfer = transfers[_tradeHash];
        require(transfer.status == Status.REGISTERED, "trade not registered or finished");
        require(_msgSender() == transfer.receiver, "must be called by receiver");
        require(isValidSignatureNow(_msgSender(), _tradeHash, _signature), "signature is invalid");
        uint256 penalty = calculatePenalty(_tradeHash);
        if (penalty > 0) transfers[_tradeHash].withdrawPenalty = penalty;
        transfers[_tradeHash].signatures.push(_signature);
        transfers[_tradeHash].status = Status.PUBLISHED;
    }

    /**
    * @notice Checks the validity of the provided signatures and give the locked
    * assets to the sender of the transaction, while charging the sender a penalty, if any
    * @param _tradeHash The hash of the trade
    * @param _signatures The array of trade participants's signatures (0 - poster, 1 - receiver)
    */

    function claim(bytes32 _tradeHash, bytes[] memory _signatures) external payable {
        TransferInfo memory transfer = transfers[_tradeHash];
        require(_msgSender() == transfer.receiver, "must be called by receiver");
        require(msg.value >= transfer.withdrawPenalty, "not enough penalty passed");
        require(transfer.status == Status.REGISTERED || transfer.status == Status.PUBLISHED, "trade completed or failed");
        require(isValidSignatureNow(transfer.poster, _tradeHash, _signatures[0]), "signature is invalid");
        require(isValidSignatureNow(transfer.receiver, _tradeHash, _signatures[1]), "signature is invalid");
        IERC20(transfer.asset).transfer(transfer.receiver, transfer.amount);
        transfers[_tradeHash].status = Status.COMPLETED;

    }   

    /**
    * @notice Returns money to the owner if trade wasn't completed (deadline is passed)
    * @param _tradeHash The hash of the trade
    */

    function withdraw(bytes32 _tradeHash) external {
        TransferInfo memory transfer = transfers[_tradeHash];
        require(
            transfer.status != Status.COMPLETED && 
            transfer.status != Status.WITHDRAWN, 
            "invalid trade status"
        );
        require(_msgSender() == transfer.poster, "caller is not poster");
        require(block.timestamp > transfer.deadline, "deadline isn't passed");
        IERC20(transfer.asset).safeTransfer(transfer.poster, transfer.amount);
        transfers[_tradeHash].status = Status.WITHDRAWN;
    }

    function calculatePenalty(bytes32 _tradeHash) public view returns(uint256){
        TransferInfo memory transfer = transfers[_tradeHash];
        uint256 lockTime_ = lockTime;
        uint256 penaltyStartsAt = transfer.deadline - lockTime_ * 2 / 3;
        uint256 penaltyIsMaxAt = penaltyStartsAt + lockTime_ / 6;
        if (block.timestamp <= penaltyStartsAt) {
            return 0;
        } else if (block.timestamp >= penaltyIsMaxAt) {
            return transfer.maxPenalty;
        } else {
            return transfer.maxPenalty * (block.timestamp - penaltyStartsAt) ** 2 / (penaltyIsMaxAt - penaltyStartsAt) ** 2;
        }
    }

    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) public view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        if (error == ECDSA.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature)
        );
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector);
    }
}