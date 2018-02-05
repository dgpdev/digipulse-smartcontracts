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


  struct DGPS_Holder {
    uint TokenAmount;
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
  }


  function depositToken(address token, address _from, uint amount) {
    require(token == DGPTaddress);
    if (!Token(token).transferFrom(msg.sender, this, amount)) throw;

    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
    balances[_from] += amount / exchangeRate;
    balances[this] -= amount / exchangeRate;

    exchangeDGPTtoDGPS(_from, amount / exchangeRate);
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }

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


  function exchangeDGPTtoDGPS(address _address, uint _amount) {
    var account = HOLDERS[_address];

    account.TokenAmount = _amount;
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


  // For unit testing only, remove before live or keep if update is desired in future.
  function setDGPTaddress(address _token) {
    DGPTaddress = _token;
  }


}
