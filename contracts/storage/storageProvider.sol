pragma solidity ^0.4.18;



/**
 * Pending Eduards integration test
 */

contract storageProvider {

  string public name = "storageProvider";
  string public version = 'v0.0.1';
  string public codename = 'beta';
  address public owner = msg.sender;

  struct VAULTS {
    string vaultId;
    string vaultHash;
    uint vaultCreationTime;
    address vaultAddress;
    uint vaultBalance;
    uint vaultLifetime;
    bool vaultState;
  }

  mapping(string => VAULTS) DigiPulseVaultString;

  function storeVaultByAddress(address _vaultAddress, string _vaultID, string _hash) public returns(address) {
    var DigiPulseNewVault = DigiPulseVaultString[_vaultID];

    DigiPulseNewVault.vaultId = _vaultID;
    DigiPulseNewVault.vaultHash = _hash;
    DigiPulseNewVault.vaultAddress = _vaultAddress;
  }

  function getID(string _id) view public returns(string) {
    var DigiPulseNewVault = DigiPulseVaultString[_id];
    return DigiPulseNewVault.vaultId;
  }


  function getHash(string _id) view public returns(string) {
    var DigiPulseNewVault = DigiPulseVaultString[_id];
    return DigiPulseNewVault.vaultHash;
  }


  function getAddress(string _id) view public returns(address) {
    var DigiPulseNewVault = DigiPulseVaultString[_id];
    return DigiPulseNewVault.vaultAddress;
  }


  // getVault - Use this function to receive an array for web3 - frontend purposes by vault's ID
  function getVault(string _id) view public returns(string, string, address) {
    var DigiPulseNewVault = DigiPulseVaultString[_id];
    return (DigiPulseNewVault.vaultId, DigiPulseNewVault.vaultHash, DigiPulseNewVault.vaultAddress);
  }


}
