var dgpsTokenContract = artifacts.require("../dgps/DgpsToken.sol");
var dgptFake = artifacts.require("../dgps/DigiPulse.sol");


contract('DGPS approval, deposit and exchange functions', function(accounts) {

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

  it("should create the DGPS contract and have 500 DGPS tokens in contract", async function () {
    let meta = await dgpsTokenContract.deployed();
    let balance = await meta.balanceOf.call(dgpsTokenContract.address);
    assert.equal(balance.valueOf(), 500 * 1e18, "500 wasn't in the first account")

    await web3.eth.sendTransaction({ from: accounts[3], to: meta.address, value: 2 * 1e18 });
    let depositEther = await web3.eth.getBalance(meta.address);
    assert.equal(depositEther.valueOf(), 2 * 1e18, "Supply did not matched expected value");
  })

  it('DGPS contract should have 0 DGPT tokens ', async function() {
    let DGPS = await dgpsTokenContract.deployed();
    let DGPT = await dgptFake.deployed();

    let intitalBalance = await DGPS.tokens.call(DGPT.address, DGPS.address);
    assert.equal(intitalBalance.toNumber(), 0);
    await DGPS.setDGPTaddress(DGPT.address);
  });

  it('DGPT should be able to approve DGPS to spend 20.000 tokens', async function() {
    let DGPS = await dgpsTokenContract.deployed();
    let DGPT = await dgptFake.deployed();

    let callApprove = await DGPT.approve(DGPS.address, 20000 * 1e18);
    assert.ok(callApprove);
  });

  it('Verify if DGPS has allowance on DGPT contract', async function() {
    let DGPS = await dgpsTokenContract.deployed();
    let DGPT = await dgptFake.deployed();

    let allowance = await DGPT.allowance(accounts[0], DGPS.address);
    assert.equal(allowance, 20000 * 1e18);
  });

  it('Account 0 should now should be able to deposit 10001 tokens to DGPS contract', async function() {
    let DGPS = await dgpsTokenContract.deployed();
    let DGPT = await dgptFake.deployed();

    let depositDGPT = await DGPS.depositToken(DGPT.address, accounts[0], 10001 * 1e18, {from: accounts[0]});
    assert.ok(depositDGPT);
  });

  it('DGPS contract should now have 10001 DGPT tokens ', async function() {
    let DGPS = await dgpsTokenContract.deployed();
    let DGPT = await dgptFake.deployed();

    let currentBalance = await DGPS.tokens.call(DGPT.address, accounts[0]);
    assert.equal(currentBalance.toNumber(), 10001 * 1e18);
  });

  it("Account 0 should have received 1.0001 DGPS tokens instead", async function () {
    let meta = await dgpsTokenContract.deployed();
    let balance = await meta.balanceOf.call(accounts[0]);
    assert.equal(balance.valueOf(), 1.0001 * 1e18, "500 wasn't in the first account")
  })


  it("User's ProfitBalance should be 0 at this point", async function () {
    let DGPS = await dgpsTokenContract.deployed();

    let userProfits = await DGPS.getHolderProfitBalance(accounts[0]);
    assert.equal(userProfits.valueOf(), 0, "Supply did not matched expected value");
  })

  it("Test if account profitbalance updates after 4 weeks", async function () {
    let DGPS = await dgpsTokenContract.deployed();

    // Note: This month only has 28 days. Took me a while to figure out....
    await timeTravel(86400 * 31);
    await mineBlock();

    let balance = await DGPS.updateBalances();
    assert.ok(balance);

    let userProfitsAfterUpdate = await DGPS.getHolderProfitBalance(accounts[0]);
    assert.equal(userProfitsAfterUpdate.valueOf(), 0.75 * 1e18, "Supply did not matched expected value");
  })




  // Keep this for end.
  it('Withdraw DGPT. Accounts should have the funds back', async function() {
    let DGPS = await dgpsTokenContract.deployed();
    let DGPT = await dgptFake.deployed();

    let intitalBalance = await DGPT.balanceOf.call(DGPS.address);
    assert.equal(intitalBalance.toNumber(), 10001 * 1e18, "initial balance should be 10k");

    let withdrawDGPT = await DGPS.withdrawToken(DGPT.address);
    assert.ok(withdrawDGPT);

    let checkContractDGPTbalance = await DGPT.balanceOf.call(DGPS.address);
    assert.equal(checkContractDGPTbalance.toNumber(), 0 ,"1");

    let checkContractDGPSbalance = await DGPS.balanceOf.call(DGPS.address);
    assert.equal(checkContractDGPSbalance.toNumber(), 500 * 1e18, "2");

    let checkAccountDGPSbalance = await DGPS.balanceOf.call(accounts[0]);
    assert.equal(checkAccountDGPSbalance.toNumber(), 0 * 1e18, "3");

    let checkAccountDGPTbalance = await DGPT.balanceOf.call(accounts[0]);
    assert.equal(checkAccountDGPTbalance.toNumber(), 50000 * 1e18, "3");
  });

});


contract ('DGPS user and company profitsharing', function(accounts) {


});
