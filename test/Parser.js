const assert = require('assert');

const Parser = artifacts.require('Parser');

let parser;

contract('Parser', function(accounts) {

	before('Should create Parser contract', async () => {
		parser = await Parser.deployed();
	});

	it('Simple rule', async () => {
		let tx = await parser.parse.call(
			[0x66,0x66,0x28,0x61,0x29,0x3a,0x2d,0x20,0x67,0x67,0x28,0x62,0x29,0x2e]
		);
		console.log(tx);
		tx = await parser.parse(
			[0x66,0x66,0x28,0x61,0x29,0x3a,0x2d,0x20,0x67,0x67,0x28,0x62,0x29,0x2e]
		);
		console.log(tx);
		// This fails because web3.js cannot handle multi-dimensional arrays as return.
		let e = await parser.encode();
		console.log(e);
	});

});
