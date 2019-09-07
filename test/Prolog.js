const assert = require('assert');

const Prolog = artifacts.require('Prolog');

let prolog;

contract('Prolog', function(accounts) {

	before('Should create Prolog contract', async () => {
		prolog = await Prolog.deployed();
	});

	it('Empty rule set', async () => {
		let solves = await prolog.solve.call(
			1,
			[2],
			[],
			[],
			[],
			[]
		);
		assert.ok(!solves[0]);
	});

	it('Goal same as rule', async () => {
		let solves = await prolog.solve.call(
			1,
			[2],
			[1],
			[[2]],
			[[]],
			[[]]
		);
		assert.ok(solves[0]);
	});

	it('Goal different atom from rule', async () => {
		let solves = await prolog.solve.call(
			1,
			[2],
			[1],
			[[3]],
			[[]],
			[[]]
		);
		assert.ok(!solves[0]);
	});

	it('Goal with variable', async () => {
		let solves = await prolog.solve.call(
			1,
			[-1],
			[1],
			[[3]],
			[[]],
			[[]]
		);
		assert.ok(solves[0]);
		assert.ok(solves[1][0][0] == -1);
		assert.ok(solves[1][0][1] == 3);
	});

	it('Goal with no matching rule', async () => {
		let solves = await prolog.solve.call(
			1,
			[-1],
			[2],
			[[3]],
			[[]],
			[[]]
		);
		assert.ok(!solves[0]);
	});

	// f(a).
	// g(X):- f(X).
	// f: 1, a: 2, g: 3, X: -1
	// goal: g(a)
	it('Rule with 1 subgoal', async () => {
		let solves = await prolog.solve.call(
			3,
			[2],
			[1, 3],
			[[2], [-1]],
			[[], [1]],
			[[], [[-1]]]
		);
		assert.ok(solves[0]);
		assert.ok(solves[1][0][0] == 2);
		assert.ok(solves[1][0][1] == 2);
	});

	// f(a).
	// g(X):- f(X).
	// f: 1, a: 2, g: 3, X: -1, Y: -2
	// goal: g(Y)
	it('Rule with 1 subgoal and goal with variable', async () => {
		let solves = await prolog.solve.call(
			3,
			[-2],
			[1, 3],
			[[2], [-1]],
			[[], [1]],
			[[], [[-1]]]
		);
		assert.ok(solves[0]);
		assert.ok(solves[1][0][0] == -2);
		assert.ok(solves[1][0][1] == 2);
	});

	// f(a).
	// g(X):- f(X), h(X).
	// h(a).
	// f: 1, a: 2, g: 3, X: -1, h: 4
	// goal: g(a)
	it('Rule with 2 subgoals', async () => {
		let solves = await prolog.solve.call(
			3,
			[2],
			[1, 3, 4],
			[[2], [-1], [2]],
			[[], [1, 4], []],
			[[], [[-1], [-1]], []]
		);
		assert.ok(solves[0]);
		assert.ok(solves[1][0][0] == 2);
		assert.ok(solves[1][0][1] == 2);
	});

	// f(a).
	// g(X):- f(X), h(X).
	// h(a).
	// f: 1, a: 2, g: 3, X: -1, h: 4, Y: -2
	// goal: g(Y)
	it('Rule with 2 subgoals and goal with variable', async () => {
		let solves = await prolog.solve.call(
			3,
			[-2],
			[1, 3, 4],
			[[2], [-1], [2]],
			[[], [1, 4], []],
			[[], [[-1], [-1]], []]
		);
		assert.ok(solves[0]);
		assert.ok(solves[1][0][0] == -2);
		assert.ok(solves[1][0][1] == 2);
	});

	// f(b).
	// f(a).
	// g(X):- f(X), h(X).
	// h(b).
	// f: 1, a: 2, g: 3, X: -1, h: 4, Y: -2, b: 5
	// goal: g(a)
	it('Rule with 2 subgoals, backtracking, and unsolvable goal', async () => {
		let solves = await prolog.solve.call(
			3,
			[2],
			[1, 1, 3, 4],
			[[5], [2], [-1], [5]],
			[[], [], [1, 4], []],
			[[], [], [[-1], [-1]], []]
		);
		assert.ok(!solves[0]);
	});

	// f(b).
	// f(a).
	// g(X):- f(X), h(X).
	// h(b).
	// h(a).
	// f: 1, a: 2, g: 3, X: -1, h: 4, Y: -2, b: 5
	// goal: g(Y)
	it('Rule with 2 subgoals, backtracking, multiple solutions', async () => {
		let solves = await prolog.solve.call(
			3,
			[-2],
			[1, 1, 3, 4, 4],
			[[5], [2], [-1], [5], [2]],
			[[], [], [1, 4], [], []],
			[[], [], [[-1], [-1]], [], []]
		);
		assert.ok(solves[0]);
		assert.ok(solves[1][0][0] == -2);
		assert.ok(solves[1][0][1] == 5);
	});

	// mother(gertrud, tanja).
	// mother(tanja, zelda).
	// grandmother(X, Y):- mother(X, Z), mother(Z, Y).
	// mother: 1, gertrud: 2, tanja: 3, zelda: 4, grandmother: 5
	// X: -1, Y: -2, Z: -3, N: -4
	// goal: grandmother(gertrud, N)
	it('Grandmother', async () => {
		let solves = await prolog.solve.call(
			5,
			[2, -4],
			[1, 1, 5],
			[[2, 3], [3, 4], [-1, -2]],
			[[], [], [1, 1]],
			[[], [], [[-1, -3], [-3, -2]]]
		);
		assert.ok(solves[0]);
		assert.ok(solves[1][0][0] == 2);
		assert.ok(solves[1][0][1] == 2);
		assert.ok(solves[1][1][0] == -4);
		assert.ok(solves[1][1][1] == 4);
	});

});
