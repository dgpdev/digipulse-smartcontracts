var dgpsTokenContract = artifacts.require("../dgps/DgpsToken.sol");
var dgptFake = artifacts.require("../dgps/DigiPulse.sol");
var mainContract = artifacts.require("./mainContract.sol");





contract('Main contract functions testing', function(accounts) {

  const timeTravel = function (time) {
    return new Promise((resolve, reject) => {
      web3.currentProvider.sendAsync({
        jsonrpc: "2.0",
        method: "evm_increaseTime",
        params: [time], // 86400 is num seconds in day
        id: new Date().getTime()
      }, (err, result) => {
        if(err){ return reject(err) }
        return resolve(result)
      });
    })
  }

  const mineBlock = function () {
    return new Promise((resolve, reject) => {
      web3.currentProvider.sendAsync({
        jsonrpc: "2.0",
        method: "evm_mine"
      }, (err, result) => {
        if(err){ return reject(err) }
        return resolve(result)
      });
    })
  }

  var profitSharingContractBalance;
  var operationalWalletBalance;


  it("should create the main contract and have 5 Ether in contract", async function () {
    let meta = await mainContract.deployed();

    await web3.eth.sendTransaction({ from: accounts[9], to: meta.address, value: 5 * 1e18 });
    let depositEther = await web3.eth.getBalance(meta.address);
    assert.equal(depositEther.valueOf(), 5 * 1e18, "Supply did not matched expected value");

    // Get accounts balances at start of test to prevent gas costs miscalculations
    profitSharingContractBalance = await web3.eth.getBalance("0xf17f52151EbEF6C7334FAD080c5704D77216b732").valueOf();
    operationalWalletBalance = await web3.eth.getBalance("0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef").valueOf();
  })

  it("should send 75% of funds to DGPS profit sharing and 25% to operational wallet for gas", async function () {
    let meta = await mainContract.deployed();
    let DGPS = await dgpsTokenContract.deployed();

    // Expect 75% of funds being transfered to DGPS.
    var expectedProfitsharing = parseInt(parseInt(profitSharingContractBalance) + parseInt(3.75 * 1e18));
    var expectedOperational = parseInt(parseInt(operationalWalletBalance) + parseInt(1.25 * 1e18));

    let depositDGPS = await meta.diversifyFunds();
    assert.ok(depositDGPS);

    let profitBalance = await web3.eth.getBalance("0xf17f52151EbEF6C7334FAD080c5704D77216b732");
    assert.equal(profitBalance.valueOf(), expectedProfitsharing);

    let operationalBalance = await web3.eth.getBalance("0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef");
    assert.equal(operationalBalance.valueOf(), expectedOperational);
  })

  it('Main contract should have 0 DGPT tokens. Call / approve for 20k DGPT ', async function() {
    let meta = await mainContract.deployed();
    let DGPT = await dgptFake.deployed();

    let intitalBalance = await meta.tokens.call(DGPT.address, meta.address);
    assert.equal(intitalBalance.toNumber(), 0);

    let callApprove = await DGPT.approve(meta.address, 20000 * 1e18);
    assert.ok(callApprove);

    let allowance = await DGPT.allowance(accounts[0], meta.address);
    assert.equal(allowance, 20000 * 1e18);

    await meta.setDGPTaddress(DGPT.address);
  });

  it('We should now should be able to deposit 10000 tokens to meta contract as funding', async function() {
    let meta = await mainContract.deployed();
    let DGPT = await dgptFake.deployed();

    let depositDGPT = await meta.depositToken(DGPT.address, accounts[0], 10000 * 1e18, {from: accounts[0]});
    assert.ok(depositDGPT);

    let currentBalance = await meta.tokens.call(DGPT.address, accounts[0]);
    assert.equal(currentBalance.toNumber(), 10000 * 1e18);
  });

  it('fastExchange should give us tokens at -10% of the price straight away', async function() {
    let meta = await mainContract.deployed();
    let DGPT = await dgptFake.deployed();

    let depositDGPT = await meta.fastExchange({ from: accounts[7], value: 1 * 1e18 });
    assert.ok(depositDGPT);

    let balanceAccount = await DGPT.balanceOf.call(accounts[7]);
    assert.equal(balanceAccount.valueOf(), 200 * 1e18, "10 wasn't in the first account")
  });




});
