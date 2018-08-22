pragma solidity ^0.4.24;

import "../openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract SimplePoS is Ownable {
    // 对所有 uint256 类型使用 SafeMath
    using SafeMath for uint256;
    // 记录所有矿工地址的数组
    address[] private allMiners;
    // 矿工地址到其 Stake 数值的映射
    mapping (address => uint256) private minerStakes;
    // 矿工地址到其在 allMiners 数组中索引的映射
    mapping (address => uint256) private allMinersIndex;
    // 当前矿工地址
    address public curMiner;
    // 所有矿工账户的余额总和
    uint256 public totalStake;

    /**
     * @dev 将合约创建者指定为第一个矿工，以保证合约的运作
     * @notice 
     */
    constructor() payable public {
        allMiners.push(msg.sender);
        minerStakes[msg.sender] = msg.value;
        totalStake = msg.value;
    }

    /**
     * @dev 为了简化处理，只允许由合约创建者添加矿工合约地址
     * @param _addr 要添加的矿工节点地址
     * @param _minerStake 矿工节点的 Stake
     * @notice 
     */
    function addMiner(address _addr, uint256 _minerStake) external onlyOwner {
        if (allMiners.length == 0 ||
            allMinersIndex[_addr] == 0 &&
            _addr != allMiners[0])
        {
            if (_minerStake == 0) {
                revert("Please deposit some ethers before registering as a miner.");
            }
            allMinersIndex[_addr] = allMiners.length;
            allMiners.push(_addr);
            minerStakes[_addr] = _minerStake;
            totalStake = totalStake.add(_minerStake);
        }
    }

    /**
     * @dev 为了简化处理，只允许由合约创建者移除矿工合约地址
     * @param _addr 要移除的矿工节点地址
     * @notice 
     */
    function removeMiner(address _addr) external onlyOwner {
        // 至少需要保留一个矿工
        require(allMiners.length > 1, "The simulator needs at least one miner to work.");

        uint256 minerIndex = allMinersIndex[_addr];
        if (minerIndex > 0 || _addr == allMiners[0]) {
            uint256 lastMinerIndex = allMiners.length.sub(1);
            address lastMiner = allMiners[lastMinerIndex];
            allMiners[minerIndex] = lastMiner;
            allMiners[lastMinerIndex] = 0;
            allMiners.length--;
            allMinersIndex[_addr] = 0;
            totalStake = totalStake.sub(minerStakes[_addr]);
            minerStakes[_addr] = 0;
        }
    }

    /**
     * @dev 基于简化的 PoS 算法选出下一个矿工地址
     * @notice 按照矿工的 Stake 在 totalStake 中的比例确定其获得记账权的几率
     */
    function selectNewMiner() public onlyOwner {

    }

}