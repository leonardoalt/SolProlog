const assert = require('assert');

const Logic = artifacts.require('LogicMock');

let logic;

contract('Logic', function(accounts) {

	before('Should create Logic library', async () => {
		logic = await Logic.deployed();
	});

	it('Numbers', async () => {
		let isNumber = await logic.isNumber([0, 1]);
		assert.ok(isNumber);
		isNumber = await logic.isNumber([1, 1]);
		assert.ok(!isNumber);
	});

	it('Literals', async () => {
		let isLiteral = await logic.isLiteral([1, 1]);
		assert.ok(isLiteral);
		isLiteral = await logic.isLiteral([0, 1]);
		assert.ok(!isLiteral);
	});

	it('Variables', async () => {
		let isVariable = await logic.isVariable([0, 1])
		assert.ok(!isVariable);
		isVariable = await logic.isVariable([2, 1]);
		assert.ok(isVariable);
	});

	it('Predicates', async () => {
		let isPredicate = await logic.isPredicate([3, 1], [[1, 2]]);
		assert.ok(isPredicate);
		isPredicate = await logic.isPredicate([3, 1], [[1, 2], [2, 3]]);
		assert.ok(isPredicate);
		isPredicate = await logic.isPredicate([0, 1], [[1, 2]]);
		assert.ok(!isPredicate);
	});
});
