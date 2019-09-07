const assert = require('assert');

const Unification = artifacts.require('UnificationMock');

let unification;

contract('Unification', function(accounts) {

	before('Should create Unification library', async () => {
		unification = await Unification.deployed();
	});

	it('Constants', async () => {
		let unifies = await unification.unify.call(1, [], 1, []);
		assert.ok(unifies);

		unifies = await unification.unify.call(1, [], 2, []);
		assert.ok(!unifies);
	});

	it('Variables', async () => {
		await unification.unify(1, [], -2, []);
		unifies = await unification.unify.call(1, [], -2, []);
		assert.ok(unifies);
		let sub = await unification.substitutions(-2);
		assert.ok(sub.toNumber() == 1);

		await unification.unify(-1, [], 2, []);
		unifies = await unification.unify.call(-1, [], 2, []);
		assert.ok(unifies);
		sub = await unification.substitutions(-1);
		assert.ok(sub.toNumber() == 2);

		unifies = await unification.unify.call(-1, [], -1, []);
		assert.ok(unifies);

		await unification.unify(-1, [], -2, []);
		unifies = await unification.unify.call(-1, [], -2, []);
		assert.ok(unifies);
		sub = await unification.substitutions(-1);
		assert.ok(sub.toNumber() == -2);
	});

	it('Predicates', async () => {
		unifies = await unification.unify.call(2, [], 1, [3]);
		assert.ok(!unifies);

		unifies = await unification.unify.call(2, [3], 1, [3, 4]);
		assert.ok(!unifies);

		unifies = await unification.unify.call(-1, [], 1, [2]);
		assert.ok(!unifies);

		unifies = await unification.unify.call(1, [2], 1, [2]);
		assert.ok(unifies);

		unifies = await unification.unify.call(1, [2], 1, [3]);
		assert.ok(!unifies);

		await unification.unify(1, [2], 1, [-3]);
		unifies = await unification.unify.call(1, [2], 1, [-3]);
		assert.ok(unifies);
		sub = await unification.substitutions(-3);
		assert.ok(sub.toNumber() == 2);

		await unification.unify(1, [-2], 1, [-3]);
		unifies = await unification.unify.call(1, [-2], 1, [-3]);
		assert.ok(unifies);
		sub = await unification.substitutions(-2);
		assert.ok(sub.toNumber() == -3);

		await unification.unify(1, [2, 3], 1, [-3, -2]);
		unifies = await unification.unify.call(1, [2, 3], 1, [-3, -2]);
		assert.ok(unifies);
		sub = await unification.substitutions(-3);
		assert.ok(sub.toNumber() == 2);
		sub = await unification.substitutions(-2);
		assert.ok(sub.toNumber() == 3);

		await unification.unify(1, [-5, 2], 1, [-8, 2]);
		unifies = await unification.unify.call(1, [-5, 2], 1, [-8, 2]);
		assert.ok(unifies);
		sub = await unification.substitutions(-5);
		assert.ok(sub.toNumber() == -8);
	});

});
