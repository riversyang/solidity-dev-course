pragma solidity ^0.4.24;

import "../openzeppelin-solidity/contracts/AddressUtils.sol";
import "../openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";

contract SimpleRndOracle is Ownable {
    // 使用 AddressUtils 库合约
    using AddressUtils for address;
    // 使用 SafeMath 库合约
    using SafeMath for uint256;
    // 接受数据回调的函数选择器常量：bytes4(keccak256("receiveRnd(uint256)"))
    bytes4 public constant CALLBACK_FUNC_SIG = 0xa46d5843;
    // 记录所有请求服务的地址的数组
    address[] private allRequesters;
    // 请求数据服务的地址到其请求计数的映射
    mapping (address => uint256) private requesterNonce;
    // 请求数据服务的地址到其当前 requestID 的映射
    mapping (address => uint256) private requestIDs;
    // requestID 到其结果接收地址的映射
    mapping (uint256 => address) private callbackAddresses;
    // 此合约所信任的唯一的数据源地址
    address private trustedDataSource;
    // 通知外部世界已经接收到一个数据请求（已成功注册一个数据请求）
    event requestRegistered(address indexed _addr, uint256 _requestID);

    /**
     * @dev 构造函数
     * @param _trustedDataSource 合约信任的外部数据服务签名地址
     * @notice 
     */
    constructor (address _trustedDataSource) public {
        trustedDataSource = _trustedDataSource;
    }

    /**
     * @dev 可接受捐赠的 fallback 函数
     */
    function() payable public {
        // empty fallback function to receive donation
    }

    /**
     * @dev 只允许 owner 调用的修改外部数据服务地址的函数
     * @param _trustedDataSource 合约信任的外部数据服务签名地址
     * @notice 
     */
    function changeTrustedDataSource(address _trustedDataSource)
        public onlyOwner
    {
        trustedDataSource = _trustedDataSource;
    }

    /**
     * @dev 只允许 owner 使用的销毁服务合约并取回捐赠的函数
     * @notice 
     */
    function destoryOracle() public onlyOwner {
        selfdestruct(owner);
    }

    /**
     * @dev 确保调用方是合约制定的信任数据源地址
     * @notice 
     */
    modifier isTrustedDataSource() {
        require(trustedDataSource == msg.sender);
        _;
    }

    /**
     * @dev 供任意合约调用的注册随机数数据请求的函数
     * @notice 
     */
    function registerRequest() external {
        // 需要注册的地址必须是合约地址
        require(msg.sender.isContract());
        // TODO: add implementation
    }

    /**
     * @dev 供外部数据服务地址调用的返回数据函数
     * @param _requestID 请求 ID
     * @param _rndNumber 返回的随机数
     * @notice 
     */
    function feedbackRndData(uint256 _requestID, uint256 _rndNumber)
        external isTrustedDataSource
    {
        // TODO: add implementation
        // 注意，回调之前需要先用 SupportsInterfaceWithLookup 接口
        // 查询接收数据的合约是否有必要的回调函数
    }

}

/**
 * @dev 接收随机数返回的 callback 接口，
 * 这里是为了简化处理，不需要用内联汇编去发起调用，
 * 实际就是要求接收返回值的合约里有一个 receiverRnd(uint256) 函数即可。
 * @notice 
 */
contract RndNumberReceiver is SupportsInterfaceWithLookup {
    function receiveRnd(uint256) public;
}
