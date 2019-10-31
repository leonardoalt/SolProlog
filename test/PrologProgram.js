const assert = require('assert');
const ethers = require('ethers');

const Program = artifacts.require('PrologProgram');

let program;

contract('PrologProgram', function(accounts) {

	before('Should create PrologProgram contract', async () => {
		program = await Program.deployed();
	});

	it('Simple rule', async () => {
		let rule = 'f(x).';
		let bytesRule = ethers.utils.toUtf8Bytes(rule);
		console.log(bytesRule);
		let tx = await program.save.call(bytesRule);
		console.log(tx);
		tx = await program.save(bytesRule);
		console.log(tx);

		let query = 'f(x)';
		let bytesQuery = ethers.utils.toUtf8Bytes(query);
		console.log(bytesQuery);
		tx = await program.query.call(bytesQuery);
		console.log('\nQuery is ' + tx + '\n');
		tx = await program.query(bytesQuery);
		console.log(tx);
	});

});
