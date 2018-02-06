pragma solidity ^ 0.4.18;

import "../libs/StandardToken.sol";
import "../libs/SafeMath.sol";


/**
 * ToDo: Limit transfer of DGPS user <-> contract only
 */

contract DgpsToken is StandardToken, SafeMath {


  string public name = "DGPS";
  string public symbol = "DGPS";
  uint8 public decimals = 18;
  string public version = 'v0.0.1';
  string public codename = 'DRONE';
  address public owner = msg.sender;
  uint public SUPPLY_TOTAL = 500 * 1e18;
  uint tokenholderCounter = 0;

  address companyWallet = 0x0F4F2Ac550A1b4e2280d04c21cEa7EBD822934b5;
  address DGPTaddress = 0x0;

  uint public exchangeRate = 10000;
  uint public contractLastPayout = 0;
  uint public lastBalanceUpdate = 0;

  struct DgpsHolder {
    uint DgpsAmount;
    uint DigiPulseAmount;
    uint ReceivedProfitsDate;
    uint ProfitBalance;
    address HolderAddress;
    bool active;
  }

  address[] public DgpsHolderArray;
  mapping(address => DgpsHolder) HOLDERS;
  mapping(address => mapping(address => uint)) public tokens;

  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);


  function DgpsToken() {
    balances[this] = 500 * 1e18;
    totalSupply = 500 * 1e18;
    contractLastPayout = now;
    lastBalanceUpdate = now;

    addDGPSholder(companyWallet, 0);
  }


  function () payable {

  }


  /*
   * Callable by anyone - This updates the balances and proceeds to payout
   * see comment below at distributeProfits()
  */
  function updateBalances() {
    require(now > lastBalanceUpdate + 4 weeks);
    require(tokenholderCounter > 0);

    uint contractBalance = this.balance / 2;
    uint entitledPayoutCompanyprofit = contractBalance / 100 * 25;
    uint entitledPayoutUserprofit = contractBalance / 100 * 75 / countHolders();

    for (uint i = 0; i < countHolders(); i++) {
      if (HOLDERS[DgpsHolderArray[i]].HolderAddress == companyWallet) {
        HOLDERS[DgpsHolderArray[i]].ProfitBalance = HOLDERS[DgpsHolderArray[i]].ProfitBalance + entitledPayoutCompanyprofit;
      }

      if (HOLDERS[DgpsHolderArray[i]].active) {
        HOLDERS[DgpsHolderArray[i]].ProfitBalance = HOLDERS[DgpsHolderArray[i]].ProfitBalance + entitledPayoutUserprofit;
      }
    }
    lastBalanceUpdate = now;
  }


  /*
   * Called seperatly for unit tests. Should be called at the end of updateBalances()
   * Make this private or internal afterwards
   *
   * Pays out all user and company profits.
  */
  function distributeProfits() {
    require(tokenholderCounter > 0);
    uint payoutAmount = 0;

    for (uint i = 0; i < countHolders(); i++) {

      address _to = HOLDERS[DgpsHolderArray[i]].HolderAddress;
      uint _amount = HOLDERS[DgpsHolderArray[i]].ProfitBalance;

      if (!_to.send(_amount)) {
        revert();
      }

      payoutAmount = payoutAmount + HOLDERS[DgpsHolderArray[i]].ProfitBalance;
      HOLDERS[DgpsHolderArray[i]].ProfitBalance = 0;
      HOLDERS[DgpsHolderArray[i]].ReceivedProfitsDate = now;
    }
    contractLastPayout = now;
  }


  /*
   * Used for DGPT deposit and exchanging to DgpsToken
  */
  function depositToken(address token, address _from, uint amount) {
    require(token == DGPTaddress);
    if (!Token(token).transferFrom(msg.sender, this, amount)) throw;

    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
    balances[_from] += amount / exchangeRate;
    balances[this] -= amount / exchangeRate;

    exchangeDGPTtoDGPS(_from, amount / exchangeRate);
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }


  /*
   * User wants to get out and get his DGPT back.
  */
  function withdrawToken(address token) {
    // Minimum 10k DGPT to withdraw
    uint amount = balances[msg.sender];
    uint DGPT = HOLDERS[msg.sender].DigiPulseAmount;

    if (!Token(token).transfer(msg.sender, DGPT)) throw;
    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], DGPT);

    balances[this] += amount;
    balances[msg.sender] -= amount;

    HOLDERS[msg.sender].ProfitBalance = 0;
    HOLDERS[msg.sender].active = false;

    Withdraw(token, msg.sender, DGPT, tokens[token][msg.sender]);
  }


  /*
   * Called by depositToken for exchanging DGPT to DgpsToken
  */
  function exchangeDGPTtoDGPS(address _address, uint _amount) private {
    var account = HOLDERS[_address];

    account.DgpsAmount = _amount;
    account.ReceivedProfitsDate = now;
    account.ProfitBalance = 0;
    account.HolderAddress = _address;
    account.DigiPulseAmount = _amount * exchangeRate;
    account.active = true;

    DgpsHolderArray.push(_address);
    tokenholderCounter++;

    Transfer(0x0, _address, _amount);
  }


  // NOTE: For unit testing only, remove before live
  function addDGPSholder(address _address, uint _amount) public {
    var account = HOLDERS[_address];

    account.DgpsAmount = _amount;
    account.ReceivedProfitsDate = now;
    account.ProfitBalance = 0;
    account.HolderAddress = _address;
    account.DigiPulseAmount = _amount * exchangeRate;
    account.active = true;

    DgpsHolderArray.push(_address);

    tokenholderCounter++;

    Transfer(0x0, _address, _amount);
  }

  function balanceOf(address token, address user) constant returns(uint) {
    return tokens[token][user];
  }

  function countHolders() view public returns(uint) {
    return DgpsHolderArray.length ;
  }

  function getHolderProfitBalance(address _address) public view returns(uint) {
    uint profit = HOLDERS[_address].ProfitBalance;
    return profit;
  }

  // NOTE: For unit testing only, remove before live or keep if update is desired in future.
  function setDGPTaddress(address _token) {
    DGPTaddress = _token;
  }


}
