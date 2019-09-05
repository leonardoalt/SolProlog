var Logic = artifacts.require("./LogicMock.sol");
var Unification = artifacts.require("./UnificationMock.sol");

module.exports = function(deployer, network, accounts) {
	deployer.deploy(Logic);
	deployer.deploy(Unification);
};
