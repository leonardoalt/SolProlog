const assert = require('assert');

const Unification = artifacts.require('UnificationMock');

let unification;

contract('Unification', function(accounts) {

	before('Should create Unification library', async () => {
		unification = await Unification.deployed();
	});

	it('Constants', async () => {
		let unifies = await unification.unify(1, [], 1, []);
		assert.ok(unifies);
		unifies = await unification.unify(1, [], 2, []);
		assert.ok(!unifies);
	});

	it('Variables', async () => {
		unifies = await unification.unify(1, [], -2, []);
		assert.ok(unifies);
		unifies = await unification.unify(-1, [], 2, []);
		assert.ok(unifies);
		unifies = await unification.unify(-1, [], -1, []);
		assert.ok(unifies);
		unifies = await unification.unify(-1, [], -2, []);
		assert.ok(unifies);
	});

	it('Predicates', async () => {
		unifies = await unification.unify(2, [], 1, [3]);
		assert.ok(!unifies);
		unifies = await unification.unify(2, [3], 1, [3, 4]);
		assert.ok(!unifies);
		unifies = await unification.unify(-1, [], 1, [2]);
		assert.ok(!unifies);
		unifies = await unification.unify(1, [2], 1, [2]);
		assert.ok(unifies);
		unifies = await unification.unify(1, [2], 1, [3]);
		assert.ok(!unifies);
		unifies = await unification.unify(1, [2], 1, [-3]);
		assert.ok(unifies);
		unifies = await unification.unify(1, [-2], 1, [-3]);
		assert.ok(unifies);
		unifies = await unification.unify(1, [2, 3], 1, [-3, -2]);
		assert.ok(unifies);
		unifies = await unification.unify(1, [-5, 2], 1, [-8, 2]);
		assert.ok(unifies);
	});

});
