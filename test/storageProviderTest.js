var storageContract = artifacts.require("./storage/storageProvider.sol");
var dgpsTokenContract = artifacts.require("./dgps/dgpsToken.sol");


contract('Storage provider contract', function(accounts) {
  const vaultID = "NbGPtis96vL4pR8XVscZrHf6i35j";
  const vaultHASH    = "000001";
  const vaultADDRESS = "0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef";


  it('Store new vault by address', async function() {
    let DGPS = await storageContract.deployed();
    let tryStore = await DGPS.storeVaultByAddress(vaultADDRESS, vaultID, vaultHASH);
    assert.ok (tryStore);
  });

  it('Get newly stored vault by address. Should return all keys by the ID.', async function() {
    let DGPS = await storageContract.deployed();

    let getID = await DGPS.getID(vaultID);
    assert.equal (getID, vaultID, "Vault ID does not match");

    let getHash = await DGPS.getHash(vaultID);
    assert.equal (getHash, vaultHASH, "Vault HASH does not match");

    let getAddress = await DGPS.getAddress(vaultID);
    assert.equal (getAddress, vaultADDRESS, "Vault A");
  });

  it('Should return an object for web3 and frontend use case', async function() {
    let DGPS = await storageContract.deployed();
    let getVAULT = await DGPS.getVault(vaultID);
    assert.ok(getVAULT, "Transaction failed");
  });

})
