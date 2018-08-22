pragma solidity ^0.4.24;

import "../openzeppelin-solidity/contracts/AddressUtils.sol";
import "../openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";

contract EthereumSimulator {
    // 使用 AddressUtils
    using AddressUtils for address;
    // 对所有 uint256 类型使用 SafeMath
    using SafeMath for uint256;
    // 记录所有矿工地址的数组
    address[] public allMiners;
    // 矿工地址到其 Stake 数值的映射
    mapping (address => uint256) private minerStakes;
    // 矿工地址到其在 allMiners 数组中索引的映射
    mapping (address => uint256) private allMinersIndex;
    // 当前矿工地址
    address public curMiner;
    // 所有矿工账户的余额总和
    uint256 public totalStake;

    constructor() public {
    }

    /**
     * @dev 矿工注册
     * @notice 
     */
    function registerMiner() external payable returns (bool) {
        // 注册的地址必须是合约
        require(msg.sender.isContract(), "Please register miner from a contract.");
        // 必须转入一定的 stake
        require(msg.value > 0, "Please deposit some ethers before registering as a miner.");
        // 检查目标合约是否实现了必要的矿工合约函数
        SupportsInterfaceWithLookup siwl = SupportsInterfaceWithLookup(msg.sender);
        require(
            siwl.supportsInterface(bytes4(keccak256("prepareToCreateBlock()"))),
            "Your contract doesn't have necessary functions."
        );
        require(
            siwl.supportsInterface(
                bytes4(keccak256("addTransaction(address,uint256,uint256,address,uint256,bytes)"))
            ),
            "Your contract doesn't have necessary functions."
        );
        require(
            siwl.supportsInterface(bytes4(keccak256("applyReward()"))),
            "Your contract doesn't have necessary functions."
        );
        require(
            siwl.supportsInterface(bytes4(keccak256("finalizeBlock()"))),
            "Your contract doesn't have necessary functions."
        );
        require(
            siwl.supportsInterface(bytes4(keccak256("applyBlock(bytes)"))),
            "Your contract doesn't have necessary functions."
        );

        if (allMiners.length == 0 || 
            allMinersIndex[msg.sender] == 0 && 
            msg.sender != allMiners[0]) 
        {
            allMinersIndex[msg.sender] = allMiners.length;
            allMiners.push(msg.sender);
            totalStake += msg.value;
            minerStakes[msg.sender] = msg.value;
            if (allMiners.length == 1) {
                curMiner = allMiners[0];
                EthereumMinerBase(curMiner).prepareToCreateBlock();
            }
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev 矿工退出
     * @notice 
     */
    function unregisterMiner() external returns (bool) {
        // 至少需要保留一个矿工
        require(allMiners.length > 1, "The simulator needs at least one miner to work.");

        uint256 minerIndex = allMinersIndex[msg.sender];
        if (minerIndex > 0 || msg.sender == allMiners[0]) {
            uint256 lastMinerIndex = allMiners.length.sub(1);
            address lastMiner = allMiners[lastMinerIndex];
            allMiners[minerIndex] = lastMiner;
            delete allMiners[lastMinerIndex];
            allMiners.length--;
            allMinersIndex[msg.sender] = 0;
            totalStake -= minerStakes[msg.sender];
            minerStakes[msg.sender] = 0;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev 基于简化的 PoS 算法选出下一个矿工地址
     * @notice 
     */
    function selectNewMiner() private {
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp))) % totalStake;
        uint256 tmpSum;
        address curAddress;
        uint minersCount = allMiners.length;
        for (uint i = 0; i < minersCount; i++) {
            curAddress = allMiners[i];
            tmpSum = tmpSum.add(minerStakes[curAddress]);
            if (tmpSum > rand) {
                curMiner = curAddress;
                break;
            }
        }
        EthereumMinerBase(curMiner).prepareToCreateBlock();
    }

    /**
     * @dev 向当前矿工发送一个交易
     * @notice 
     */
    function processTransaction(
        uint256 _gasLimit,
        uint256 _gasPrice,
        address _to,
        uint256 _value,
        bytes _data
    )
        external
    {
        require(allMiners.length > 0, "Need at least one miner.");
        EthereumMinerBase(curMiner).applyReward();
        EthereumMinerBase(curMiner).addTransaction(msg.sender, _gasLimit, _gasPrice, _to, _value, _data);
        bytes memory blockData = EthereumMinerBase(curMiner).finalizeBlock();
        for (uint256 i = 0; i < allMiners.length; i++) {
            if (allMiners[i] != curMiner) {
                EthereumMinerBase(allMiners[i]).applyBlock(blockData);
            }
        }
        selectNewMiner();
    }

}

interface EthereumMinerBase {
    function prepareToCreateBlock() external;
    function addTransaction(address, uint256, uint256, address, uint256, bytes) external;
    function applyReward() external;
    function finalizeBlock() external returns (bytes);
    function applyBlock(bytes) external;
}