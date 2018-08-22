pragma solidity ^0.4.24;

import "../openzeppelin-solidity/contracts/math/SafeMath.sol";

contract EthereumWorldState {
    // 对所有 uint256 类型使用 SafeMath
    using SafeMath for uint256;
    // 空字符串的哈希值常量
    bytes32 constant EMPTY_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // AccountState struct
    struct AccountState {
        uint256 nonce;
        uint256 balance;
        bytes32 storageRoot;
        bytes32 codeHash;
    }
    // StateTrie data struct
    struct StateData {
        mapping(address => AccountState) stateTrie;
        mapping(address => bytes) codeTrie;
        mapping(address => mapping(uint256 => bytes32)) storageTrie;
    }

    StateData internal worldState;

    function createContractAccount(
        address _addr,
        uint256 _value,
        bytes _codeBinary
    )
        internal
    {
        bytes32 _codeHash;

        if (_codeBinary.length > 0) {
            // 计算传入代码的 code 哈希
            _codeHash = keccak256(_codeBinary);
            worldState.codeTrie[_addr] = _codeBinary;
        } else {
            // 使用常数作为 code 哈希
            _codeHash = EMPTY_HASH;
        }

        worldState.stateTrie[_addr] = AccountState({
            nonce: 0, balance: _value,
            storageRoot: EMPTY_HASH, codeHash: _codeHash
        });
    }

    function hasCode(address _addr) public view returns (bool) {
        return (worldState.stateTrie[_addr].codeHash ^ EMPTY_HASH != 0);
    }

    function getCode(address _addr) public view returns (bytes) {
        return worldState.codeTrie[_addr];
    }

    function getNonce(address _addr) public view returns (uint256) {
        return worldState.stateTrie[_addr].nonce;
    }

    function addNonce(address _addr) internal returns (uint256) {
        worldState.stateTrie[_addr].nonce = worldState.stateTrie[_addr].nonce.add(1);
        return worldState.stateTrie[_addr].nonce;
    }

    function getBalance(address _addr) public view returns (uint256) {
        return worldState.stateTrie[_addr].balance;
    }

    function addBalance(address _addr, uint256 _value) internal returns (uint256) {
        worldState.stateTrie[_addr].balance = worldState.stateTrie[_addr].balance.add(_value);
        return worldState.stateTrie[_addr].balance;
    }

    function subBalance(address _addr, uint256 _value) internal returns (uint256) {
        require(worldState.stateTrie[_addr].balance >= _value, "Balance is not enough.");
        worldState.stateTrie[_addr].balance = worldState.stateTrie[_addr].balance.sub(_value);
        return worldState.stateTrie[_addr].balance;
    }

}