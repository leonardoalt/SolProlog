const assert = require('assert');

const Unification = artifacts.require('UnificationMock');

let unification;

contract('Unification', function(accounts) {

	before('Should create Unification library', async () => {
		unification = await Unification.deployed();
	});

	it('Numbers', async () => {
		let unifies = await unification.unify.call([0, 1], [], [0, 1], []);
		assert.ok(unifies);

		unifies = await unification.unify.call([0, 1], [], [0, 2], []);
		assert.ok(!unifies);
	});

	it('Literals', async () => {
		let unifies = await unification.unify.call([1, 1], [], [1, 1], []);
		assert.ok(unifies);

		unifies = await unification.unify.call([1, 1], [], [1, 2], []);
		assert.ok(!unifies);
	});

	it('Variables', async () => {
		await unification.unify([1, 1], [], [2, 2], []);
		unifies = await unification.unify.call([1, 1], [], [2, 2], []);
		assert.ok(unifies);
		// The first argument is the substituted variable
		// The second argument is the index in the returned uint[2]
		let sub = await unification.substitutions(2, 1);
		assert.ok(sub.toNumber() == 1);

		await unification.unify([2, 1], [], [1, 2], []);
		unifies = await unification.unify.call([2, 1], [], [1, 2], []);
		assert.ok(unifies);
		sub = await unification.substitutions(1, 1);
		assert.ok(sub.toNumber() == 2);

		unifies = await unification.unify.call([2, 1], [], [2, 1], []);
		assert.ok(unifies);

		await unification.unify([2, 1], [], [2, 2], []);
		unifies = await unification.unify.call([2, 1], [], [2, 2], []);
		assert.ok(unifies);
		sub = await unification.substitutions(1, 1);
		assert.ok(sub.toNumber() == 2);
	});

	it('Predicates', async () => {
		unifies = await unification.unify.call([1, 2], [], [3, 1], [[1, 3]]);
		assert.ok(!unifies);

		unifies = await unification.unify.call([3, 2], [[1, 3]], [3, 1], [[1, 3], [1, 4]]);
		assert.ok(!unifies);

		unifies = await unification.unify.call([2, 1], [], [3, 1], [[1, 2]]);
		assert.ok(!unifies);

		unifies = await unification.unify.call([3, 1], [[1, 2]], [3, 1], [[1, 2]]);
		assert.ok(unifies);

		unifies = await unification.unify.call([3, 1], [[1, 2]], [3, 1], [[1, 3]]);
		assert.ok(!unifies);

		await unification.unify([3, 1], [[1, 2]], [3, 1], [[2, 3]]);
		unifies = await unification.unify.call([3, 1], [[1, 2]], [3, 1], [[2, 3]]);
		assert.ok(unifies);
		sub = await unification.substitutions(3, 1);
		assert.ok(sub.toNumber() == 2);

		await unification.unify([3, 1], [[2, 2]], [3, 1], [[2, 3]]);
		unifies = await unification.unify.call([3, 1], [[2, 2]], [3, 1], [[2, 3]]);
		assert.ok(unifies);
		sub = await unification.substitutions(2, 1);
		assert.ok(sub.toNumber() == 3);

		await unification.unify([3, 1], [[1, 2], [1, 3]], [3, 1], [[2, 3], [2, 2]]);
		unifies = await unification.unify.call([3, 1], [[1, 2], [1, 3]], [3, 1], [[2, 3], [2, 2]]);
		assert.ok(unifies);
		sub = await unification.substitutions(3, 1);
		assert.ok(sub.toNumber() == 2);
		sub = await unification.substitutions(2, 1);
		assert.ok(sub.toNumber() == 3);

		await unification.unify([3, 1], [[2, 5], [1, 2]], [3, 1], [[2, 8], [1, 2]]);
		unifies = await unification.unify.call([3, 1], [[2, 5], [1, 2]], [3, 1], [[2, 8], [1, 2]]);
		assert.ok(unifies);
		sub = await unification.substitutions(5, 1);
		assert.ok(sub.toNumber() == 8);
	});

});
