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

  address companyWallet = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;
  address DGPTaddress = 0x0;


  uint public exchangeRate = 10000;
  uint public contractLastPayout = 0;


  struct DGPS_Holder {
    uint DgpsAmount;
    uint DigiPulseAmount;
    uint ReceivedProfitsDate;
    uint ProfitBalance;
    address HolderAddress;
  }

  address[] public holderArray;
  mapping(address => DGPS_Holder) HOLDERS;
  mapping(address => mapping(address => uint)) public tokens;

  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);

  function DgpsToken() {
    balances[this] = 500 * 1e18;
    totalSupply = 500 * 1e18;
    contractLastPayout = now;
  }

  function () payable {

  }

  function updateBalances() {
    require(now > contractLastPayout + 4 weeks);
    require(tokenholderCounter > 0);

    uint contractBalance = this.balance / 2;
    uint entitledPayoutCompanyprofit = contractBalance / 100 * 25;
    uint entitledPayoutUserprofit = contractBalance / 100 * 75 / countHolders();

    for (uint i = 0; i < countHolders(); i++) {
      if (HOLDERS[holderArray[i]].HolderAddress == companyWallet) {
        HOLDERS[holderArray[i]].ProfitBalance = HOLDERS[holderArray[i]].ProfitBalance + entitledPayoutCompanyprofit;
      }
      HOLDERS[holderArray[i]].ProfitBalance = HOLDERS[holderArray[i]].ProfitBalance + entitledPayoutUserprofit;
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

    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], DGPT);
    if (!Token(token).transfer(msg.sender, DGPT)) throw;
    Withdraw(token, msg.sender, DGPT, tokens[token][msg.sender]);

    balances[this] += amount;
    balances[msg.sender] -= amount;
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

    holderArray.push(_address);
    tokenholderCounter++;

    Transfer(0x0, _address, _amount);
  }


  function balanceOf(address token, address user) constant returns(uint) {
    return tokens[token][user];
  }

  function countHolders() view public returns(uint) {
    return holderArray.length;
  }

  function getHolderProfitBalance(address _address) public view returns(uint) {
    //DGPS_Holder storage account = DgpsHolders[_address];
    uint ret = HOLDERS[_address].ProfitBalance;
    return ret;
  }

  // NOTE: For unit testing only, remove before live or keep if update is desired in future.
  function setDGPTaddress(address _token) {
    DGPTaddress = _token;
  }


}
