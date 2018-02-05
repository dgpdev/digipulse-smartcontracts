var dgpsTokenContract = artifacts.require("../dgps/DgpsToken.sol");
var dgptFake = artifacts.require("../dgps/DigiPulse.sol");

contract('DGPS approval, deposit and exchange functions', function(accounts) {

  it("should create the DGPS contract and have 500 DGPS tokens in contract", async function () {
    let meta = await dgpsTokenContract.deployed();
    let balance = await meta.balanceOf.call(dgpsTokenContract.address);
    assert.equal(balance.valueOf(), 500 * 1e18, "500 wasn't in the first account")
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

  it('Withdraw DGPT. All accounts should have the funds back', async function() {
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
