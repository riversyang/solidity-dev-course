var GasOptimizeSample = artifacts.require("../contracts/week4/GasOptimizeSample");

contract('GasOptimizeSample', function(accounts) {
    var instanceFuture = GasOptimizeSample.new();
    var totalGas = 0;

    it("Passes testcase 1 ", async function() {
        let defaultValue = 1000;
        let defaultGas = 1000000;
        let instance = await instanceFuture;
        await instance.bet(2, {from: accounts[0], value: defaultValue, gas: defaultGas});
        await instance.bet(3, {from: accounts[1], value: defaultValue, gas: defaultGas});
        await instance.bet(6, {from: accounts[2], value: defaultValue, gas: defaultGas});
        await instance.bet(7, {from: accounts[3], value: defaultValue, gas: defaultGas});
        await instance.bet(1, {from: accounts[4], value: defaultValue, gas: defaultGas});
        await instance.bet(4, {from: accounts[5], value: defaultValue, gas: defaultGas});
        await instance.bet(8, {from: accounts[6], value: defaultValue, gas: defaultGas});
        await instance.bet(9, {from: accounts[7], value: defaultValue, gas: defaultGas});
        await instance.bet(4, {from: accounts[8], value: defaultValue, gas: defaultGas});
        // 第 10 次下注前先预估一下这次调用会花费的 gas，这是基于前 9 次下注之后的状态
        let curGas = 0;
        curGas = await instance.bet.estimateGas(10, {from: accounts[9], value: defaultValue, gas: defaultGas}) - 21000;
        console.log(curGas);
        totalGas += curGas;
        // 实际执行第 10 次下注
        await instance.bet(10, {from: accounts[9], value: defaultValue, gas: defaultGas});
        // 验证合约的处理结果
        let curBalance = 0;
        for (let i = 0; i < 10; i++) {
            curBalance = await instance.playerBalance.call({from: accounts[i], gas: defaultGas});
            assert.equal(curBalance, defaultValue);
        }
    });

    it("Passes testcase 2 " , async function() {
        let defaultValue = 1000;
        let defaultGas = 1000000;
        let instance = await instanceFuture;
        await instance.bet(5, {from: accounts[0], value: defaultValue, gas: defaultGas});
        await instance.bet(5, {from: accounts[1], value: defaultValue, gas: defaultGas});
        await instance.bet(5, {from: accounts[2], value: defaultValue, gas: defaultGas});
        await instance.bet(5, {from: accounts[3], value: defaultValue, gas: defaultGas});
        await instance.bet(5, {from: accounts[4], value: defaultValue, gas: defaultGas});
        await instance.bet(7, {from: accounts[5], value: defaultValue, gas: defaultGas});
        await instance.bet(3, {from: accounts[6], value: defaultValue, gas: defaultGas});
        await instance.bet(9, {from: accounts[7], value: defaultValue, gas: defaultGas});
        await instance.bet(1, {from: accounts[8], value: defaultValue, gas: defaultGas});
        // 第 10 次下注前先预估一下这次调用会花费的 gas，这是基于前 9 次下注之后的状态
        let curGas = 0;
        curGas = await instance.bet.estimateGas(10, {from: accounts[9], value: defaultValue, gas: defaultGas}) - 21000;
        console.log(curGas);
        totalGas += curGas;
        // 实际执行第 10 次下注
        await instance.bet(10, {from: accounts[9], value: defaultValue, gas: defaultGas});
        // 验证合约的处理结果
        let curBalance = 0;
        for (let i = 0; i < 5; i++) {
            curBalance = await instance.playerBalance.call({from: accounts[i], gas: defaultGas});
            assert.equal(curBalance, 3000);
        }
    });

    after(async function() {
        console.log("Total gas for the 10th bet(): " + totalGas);
    });

});