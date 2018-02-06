pragma solidity ^ 0.4.18;

import "./libs/StandardToken.sol";
import "./libs/SafeMath.sol";

/**
- Accept ETH/EUR/BTC/USD through 3rd party API
- API success puts buy order on the selected exchanges
+ Immediately give tokens from our own supply on 10% lower exchange rate (so we have margin for trading)
- Min 1k EUR equiv. In DGPT is being sent each month to storage providers
- Once the storage provider profit share surpasses 1000 EUR equiv. 10% from the amount over the 1000 are being diverted to the company token pool, until the company token pool once again has 25% from the total token supply
- DGPT 50% are being exchanged to the ETH for DGPS profit share and Gas price coverage
+ 75% of ETH received on the smart contract are being sent over to DGPS smart contract as profit share,
* while 25% are sent to the wallet which operates with the smart contract for gas cost coverage for 30 days. After 30 days the remainder of “25% Gas ETH” is also sent as profit sharing.
 */

contract mainContract is StandardToken, SafeMath {

  address profitSharingContract = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;
  address operationalWallet     = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;
  address DGPTaddress           = 0x0;  // set by function for unit tests
  address owner                 = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE;
  address allowedPurchaser      = 0x0;  // set by function for unit tests

  uint averageGasCost30Days     = 1 * 1e18;
  uint exchangeRate             = 200;    // replace by pricesource. Simulation that 1 eth = 200 DGPT

  struct TokenPurchase {
    uint timestamp;
    uint token_amount;
    uint token_price;
    string payment_method;
    string payment_currency;
    bool approved;
    address signed;

  }

  address[] public TokenPurchaseArray;

  mapping(address => TokenPurchase) TokenPurchases;
  mapping(address => mapping(address => uint)) public tokens;


  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);


  function buyTokens(uint _amount, address _destinator, string _method, string _currency) internal {

    if (!Token(DGPTaddress).transfer(_destinator, _amount)) throw;
    //tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], _amount);

    var purchase = TokenPurchases[_destinator];
    purchase.timestamp = now;
    purchase.token_amount = _amount;
    purchase.token_price = 0;
    purchase.payment_method = _method;
    purchase.payment_currency = _currency;
    purchase.approved = true;
    purchase.signed = msg.sender;

    TokenPurchaseArray.push(_destinator);
  }

  function mainContract() {

  /**
   *
   */

  }

  function () payable {

  }

  /**
   * fastExchange - User get's DGPT at 10% reduction when sending ETH
   */
  function fastExchange() payable {
    uint totalTokens = msg.value * exchangeRate;
    buyTokens(totalTokens, msg.sender, "ETHEREUM", "ETH");
  }


  /**
   * remotePurchase - Used for remote API purchases. These can be called on the platform and then make a call to this function.
   * Can only be called from the allowedPurchaser wallet.
   *
   *  uint _amount            Amount of DGPT tokens to send
   *  address _destinator  Address of user to receive tokens
   *  string _method        What method did we use? PayPal, Eth, Bitcoin, ....
   *  string _currency      Shortcut for currency used. EUR, USD, ETH, PPL, ...
   */
  function remotePurchase(uint _amount, address _destinator, string _method, string _currency) {
    require(msg.sender == allowedPurchaser);
    buyTokens(_amount, _destinator, _method, _currency);
  }


  /**
   * diversifyFunds - Split balances between DGPS contract for profit and controlling wallet for gas costs.
   */
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


  /**
   * depositToken - Allows us to deposit DGPT (and other) token on the contract.
   *
   * address token    What token will we deposit?
   * address _from    can be removed
   * uint amount         how many tokens will we deposit?
   */
  function depositToken(address token, address _from, uint amount) {
    if (!Token(token).transferFrom(msg.sender, this, amount)) throw;
    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }


  function withdrawToken(address token) {

  }

  // NOTE: For unit testing only, remove before live or keep if update is desired in future.
  function setDGPTaddress(address _token) {
    DGPTaddress = _token;
  }
  function setAllowedPurchaser(address _token) {
    allowedPurchaser = _token;
  }

}
