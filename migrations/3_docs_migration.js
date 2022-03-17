
const Contract = artifacts.require("DocDigests");

module.exports = function (deployer) {
  deployer.deploy(Contract);
};