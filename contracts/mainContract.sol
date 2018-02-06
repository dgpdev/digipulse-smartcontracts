pragma solidity ^ 0.4.18;

import "./libs/StandardToken.sol";
import "./libs/SafeMath.sol";

/**
- Accept ETH/EUR/BTC/USD through 3rd party API
- API success puts buy order on the selected exchanges
- Immediately give tokens from our own supply on 10% lower exchange rate (so we have margin for trading)
- Min 1k EUR equiv. In DGPT is being sent each month to storage providers
- Once the storage provider profit share surpasses 1000 EUR equiv. 10% from the amount over the 1000 are being diverted to the company token pool, until the company token pool once again has 25% from the total token supply
- DGPT 50% are being exchanged to the ETH for DGPS profit share and Gas price coverage
+ 75% of ETH received on the smart contract are being sent over to DGPS smart contract as profit share,
* while 25% are sent to the wallet which operates with the smart contract for gas cost coverage for 30 days. After 30 days the remainder of “25% Gas ETH” is also sent as profit sharing.
 */

contract mainContract is StandardToken, SafeMath {

  address profitSharingContract = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;
  address operationalWallet     = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;

  uint averageGasCost30Days     = 1 * 1e18;

  struct TokenPurchase {
    uint timestamp;
    uint token_amount;
    uint token_price;
    string payment_method;
    string payment_currency;
    bool approved;

  }

  address[] public TokenPurchaseArray;

  mapping(address => TokenPurchase) TokenPurchases;
  mapping(address => mapping(address => uint)) public tokens;


  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);


  function buyTokens(address token, uint _amount, address _destinator) {

    if (!Token(token).transfer(_destinator, _amount)) throw;
    //tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], _amount);

    var purchase = TokenPurchases[_destinator];
    purchase.timestamp = now;
    purchase.token_amount = _amount;
    purchase.token_price = 0;
    purchase.payment_method = "ETH";
    purchase.payment_currency = "PAYPAL";
    purchase.approved = false;

    TokenPurchaseArray.push(_destinator);
  }

  function mainContract() {

  /**
   *
   */

  }

  function () payable {

  }

  function diversifyFunds() {
    uint fundDGPS = this.balance / 100 * 75;
    uint fundOperational = this.balance / 100 * 25;

    if (!profitSharingContract.send(fundDGPS)) {
      revert();
    }

    if (!operationalWallet.send(fundOperational)) {
      revert();
    }
  }


  function depositToken(address token, address _from, uint amount) {
    if (!Token(token).transferFrom(msg.sender, this, amount)) throw;
    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function withdrawToken(address token) {

  }


}
