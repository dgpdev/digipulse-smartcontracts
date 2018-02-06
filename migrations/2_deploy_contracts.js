var storageProvider = artifacts.require("./storage/storageProvider.sol");
var DigipulseFakeToken = artifacts.require("./dgps/DigiPulse.sol");
var dgpsToken = artifacts.require("./dgps/dgpsToken.sol");
var mainContract = artifacts.require("./mainContract.sol");




module.exports = function(deployer) {
  deployer.deploy(storageProvider);
  deployer.deploy(DigipulseFakeToken);
  deployer.deploy(dgpsToken);
  deployer.deploy(mainContract);


};
