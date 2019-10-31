var Logic = artifacts.require("./LogicMock.sol");
var Unification = artifacts.require("./UnificationMock.sol");
var Prolog = artifacts.require("./Prolog.sol");
var Encoder = artifacts.require("./Encoder.sol");
var Parser = artifacts.require("./Parser.sol");
var Program = artifacts.require("./PrologProgram.sol");

module.exports = function(deployer, network, accounts) {
	deployer.deploy(Logic);
	deployer.deploy(Unification);
	deployer.deploy(Prolog);
	deployer.deploy(Encoder);
	deployer.link(Encoder, Parser);
	deployer.deploy(Program);
	deployer.link(Program, Parser);
	deployer.deploy(Parser);
};
