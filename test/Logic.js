const assert = require('assert');

const Logic = artifacts.require('LogicMock');

let logic;

contract('Logic', function(accounts) {

	before('Should create Logic library', async () => {
		logic = await Logic.deployed();
	});

	it('Constants', async () => {
		let isConstant = await logic.isConstant(1);
		assert.ok(isConstant);
		isConstant = await logic.isConstant(-1);
		assert.ok(!isConstant);
	});

	it('Variables', async () => {
		let isVariable = await logic.isVariable(1);
		assert.ok(!isVariable);
		isVariable = await logic.isVariable(-1);
		assert.ok(isVariable);
	});

	it('Predicates', async () => {
		let isPredicate = await logic.isPredicate(1, [2]);
		assert.ok(isPredicate);
		isPredicate = await logic.isPredicate(1, [2, -3]);
		assert.ok(isPredicate);
		isPredicate = await logic.isPredicate(1, []);
		assert.ok(!isPredicate);
		isPredicate = await logic.isPredicate(-1, [2]);
		assert.ok(!isPredicate);
	});
});
