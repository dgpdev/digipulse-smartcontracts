pragma solidity ^ 0.4.18;

import "../libs/StandardToken.sol";


/**
 * Fake token for testing. Remove before live
 */

contract DigiPulse is StandardToken {
  string public name = "TestToken";
  string public symbol = "DGPTEST";
  uint8 public decimals = 18;
  string public version = 'v0.0.1';
  string public codename = 'DRONE';
  address public owner = msg.sender;
  uint public SUPPLY_TOTAL = 800 * 1e18;

  function DigiPulse() {
    balances[msg.sender] = 50000 * 1e18; // Tokens to be issued during the crowdsale
    Transfer(0x0, this, 50000 * 1e18);
    totalSupply = 50000 * 1e18;
  }
}
