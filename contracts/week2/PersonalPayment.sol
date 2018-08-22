pragma solidity ^0.4.24;

import "../openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity/contracts/payment/PullPayment.sol";

contract PersonalPayment is Ownable, PullPayment {
    // 使用 SafeMath
    using SafeMath for uint256;
    // TODO: 添加必要的状态变量、事件定义和其他必要的函数

    function asyncPay(address _dest, uint256 _amount) public onlyOwner {
        // TODO
    }

    function withdrawPayments() public {
        // TODO
    }

    function destroy() public onlyOwner {
        // TODO
    }

}