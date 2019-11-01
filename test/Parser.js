const assert = require('assert');
const ethers = require('ethers');

const Parser = artifacts.require('Parser');

let parser;

contract('Parser', function(accounts) {

	before('Should create Parser contract', async () => {
		parser = await Parser.deployed();
	});

	it('Simple rule', async () => {
		let rule = 'ff(a):- gg(b).';
		let tx = await parser.parse.call(
			ethers.utils.toUtf8Bytes(rule)
		);
		console.log(tx);
		tx = await parser.parse(
			ethers.utils.toUtf8Bytes(rule)
		);
		console.log(tx);
		//let e = await parser.encode();
		//console.log(e);
	});

});
