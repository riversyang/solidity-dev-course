var EthereumSimulator = artifacts.require("./EthereumSimulator.sol");

module.exports = function(deployer) {
    deployer.deploy(EthereumSimulator);
};
