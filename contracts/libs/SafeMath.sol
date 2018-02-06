pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert() on error
 */
contract SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    asserts(a == 0 || c / a == b);
    return c;
  }
  function safeSub(uint a, uint b) internal pure returns (uint) {
    asserts(b <= a);
    return a - b;
  }
  function safeMul(uint a, uint b) internal returns(uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function safeAdd(uint a, uint b) internal returns(uint) {
    uint c = a + b;
    assert(c >= a && c >= b);
    return c;
  }
  function div(uint a, uint b) internal pure returns (uint) {
    asserts(b > 0);
    uint c = a / b;
    asserts(a == b * c + a % b);
    return c;
  }
  function sub(uint a, uint b) internal pure returns (uint) {
    asserts(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    asserts(c >= a);
    return c;
  }
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }
  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }
  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
  function asserts(bool assertion) internal pure {
    if (!assertion) {
      revert();
    }
  }
}
