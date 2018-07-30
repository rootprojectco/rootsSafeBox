var RootsSafeBoxFactory = artifacts.require("./RootsSafeBoxFactory.sol");

const configs = require('./../configs/config');

module.exports = function(deployer) {
  deployer.deploy(
      RootsSafeBoxFactory,
      configs.tokenAddress
  );
};
