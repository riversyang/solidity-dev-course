var Sort = artifacts.require("../contracts/week4/Sort");
var testdata = require('../data/Sort.json');

contract('Sort', function(accounts) {
    var instanceFuture = Sort.new();
    var totalGas = 0;
    testdata.vectors.forEach(function(v, i) {
        it("Passes test vector " + i, async function() {
            var instance = await instanceFuture;
            var curGas = 0;
            curGas = await instance.sort.estimateGas(v.input[0], {gas: v.gas}) - 21000;
            totalGas += curGas;
            console.log("Gas estimation for Sort input " + i + " : " + curGas);
            var result = await instance.sort(v.input[0], {gas: v.gas});
            assert.deepEqual(result.map(x => x.toNumber()), v.output[0]);
        });
    });

    after(async function() {
        console.log("Total gas for Sort: " + totalGas);
    });
});