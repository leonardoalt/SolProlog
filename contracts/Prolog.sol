pragma solidity >=0.5.8;
pragma experimental ABIEncoderV2;

import './Logic.sol';
import './Unification.sol';

/**
 * @title A Prolog solver
 * @notice This contract solves predicate goals given a set of rules
 * based on the Prolog unification and backtracking algorithms.
 * @dev This needs to be a contract instead of a library because of the fresh variable counter.
 * The encoding used to receive goals and rules does not support lists, disjunctions, nested
 * predicates and metapredicates.
 */
contract Prolog {
	/// @dev Prolog rule with head and subgoals.
	struct Rule {
		Logic.Term head;
		Logic.Term[] tail;
	}

	/// @dev Symbol substitution.
	struct Substitution {
		uint variable;
		uint[2] atom;
	}

	/// @dev Stack of substitutions that are made while solving.
	mapping (uint => uint[2])[] substitutions;

	/// @dev Fresh variable counters for unification between variables from goal and
	/// matched rule subgoals.
	uint currentFreshVariable = 1000;

	/**
	 * @notice Tries to solve a predicate goal given a set of rules.
	 * @dev The input needs to be encoded previously into a format that uses only arrays
	 * because those can be passed as `memory` parameters in `public` functions, as opposed
	 * to recursive structs such as `Logic.Term`. The encoding is explained below.
	 * The encoding used to receive goals and rules does not support lists, disjunctions, nested
	 * predicates and metapredicates.
	 * @param _goalSymbol The goal predicate symbol
	 * @param _goalArguments The goal argument symbols
	 * @param _rulesSymbols The predicate symbol for each rule from the rule set
	 * @param _rulesArguments For each rule, a list of predicate arguments
	 * @param _subGoalsSymbols For each rule, a list of subgoal predicate symbols
	 * @param _subGoalsArguments For each subgoal of each rule, a list of predicate arguments
	 * @return Whether the goal is solved, and if is, a list of substitutions that solve the goal
	 */
	function solve(
		uint[2] memory _goalSymbol,
		uint[2][] memory _goalArguments,
		uint[2][] memory _rulesSymbols,
		uint[2][][] memory _rulesArguments,
		uint[2][][] memory _subGoalsSymbols,
		uint[2][][][] memory _subGoalsArguments
	) public returns (bool, Substitution[] memory) {
		require(_goalArguments.length > 0);
		Logic.Term[] memory goals = new Logic.Term[](1);
		goals[0] = Logic.parseIntoTerm(_goalSymbol, _goalArguments);

		require(_rulesSymbols.length == _rulesArguments.length);
		require(_rulesSymbols.length == _subGoalsSymbols.length);
		require(_rulesSymbols.length == _subGoalsArguments.length);

		Rule[] memory rules = new Rule[](_rulesSymbols.length);
		for (uint i = 0; i < _rulesSymbols.length; ++i) {
			require(_rulesArguments[i].length > 0);
			rules[i].head = Logic.parseIntoTerm(_rulesSymbols[i], _rulesArguments[i]);
			rules[i].tail = new Logic.Term[](_subGoalsSymbols[i].length);
			for (uint j = 0; j < _subGoalsSymbols[i].length; ++j) {
				require(_subGoalsArguments[i][j].length > 0);
				rules[i].tail[j] = Logic.parseIntoTerm(_subGoalsSymbols[i][j], _subGoalsArguments[i][j]);
			}
		}

		bool result = query(goals, rules);

		Substitution[] memory subs = new Substitution[](_goalArguments.length);
		for (uint i = 0; i < _goalArguments.length; ++i) {
			subs[i].variable = _goalArguments[i][1];
			if (_goalArguments[i][0] == uint(Logic.TermKind.Variable))
				subs[i].atom = findSubstitution(_goalArguments[i][1]);
			else {
				subs[i].atom[0] = _goalArguments[i][0];
				subs[i].atom[1] = subs[i].variable;
			}
		}

		delete substitutions;

		return (result, subs);
	}

	/**
	 * @notice Given a set of rules and goals, try to solve each goal recursively or backtrack when not possible.
	 * @param _goals The list of goals to be solved
	 * @param _rules The rule set
	 * @return Whether the given goals are solved.
	 */
	function query(Logic.Term[] memory _goals, Rule[] memory _rules) internal returns (bool) {
		if (_goals.length == 0)
			return true;

		Logic.Term memory frontGoal = _goals[0];
		for (uint i = 0; i < _rules.length; ++i) {
			substitutions.length++;
			mapping (uint => uint[2]) storage subs = substitutions[substitutions.length - 1];

			bool unified = Unification.unify(frontGoal, _rules[i].head, subs);
			if (!unified)
				continue;

			substitutions.length++;
			mapping (uint => uint[2]) storage newSubs = substitutions[substitutions.length - 1];

			buildNewSubstitutions(frontGoal.arguments, subs, newSubs);
			buildNewSubstitutions(_rules[i].head.arguments, subs ,newSubs);

			Logic.Term[] memory newGoals = new Logic.Term[](_goals.length - 1 + _rules[i].tail.length);
			for (uint j = 1; j < _goals.length; ++j)
				appendNewGoal(_goals[j], newGoals[j - 1], newSubs);
			for (uint j = 0; j < _rules[i].tail.length; ++j)
				appendNewGoal(_rules[i].tail[j], newGoals[j + _goals.length - 1], newSubs);

			substitutions.length--;

			bool result = query(newGoals, _rules);
			if (result)
				return true;

			substitutions.length--;
		}

		return false;
	}

	function appendNewGoal(
		Logic.Term memory _goal,
		Logic.Term memory _newGoal,
		mapping (uint => uint[2]) storage _substitutions
	) internal view {
		_newGoal.kind = _goal.kind;
		_newGoal.symbol = _goal.symbol;
		_newGoal.arguments = new Logic.Term[](_goal.arguments.length);
		for (uint i = 0; i < _goal.arguments.length; ++i) {
			uint argSymbol = _goal.arguments[i].symbol;
			uint[2] memory sub = _substitutions[argSymbol];
			if (sub[1] != 0)
				_newGoal.arguments[i] = Logic.parseIntoTerm(sub);
			else
				_newGoal.arguments[i] = _goal.arguments[i];
		}
	}

	function buildNewSubstitutions(
		Logic.Term[] memory _args,
		mapping (uint => uint[2]) storage oldSubs,
		mapping (uint => uint[2]) storage newSubs
	) internal {
		for (uint i = 0; i < _args.length; ++i) {
			uint argSymbol = _args[i].symbol;
			uint[2] memory sub = oldSubs[argSymbol];
			if (sub[1] != 0) {
				if (sub[0] == uint(Logic.TermKind.Number) || sub[0] == uint(Logic.TermKind.Literal))
					newSubs[argSymbol] = sub;
				else
					newSubs[argSymbol] = [sub[0], freshVariableSymbol()];
			}
		}
	}

	function findSubstitution(uint _variable) internal view returns (uint[2] memory) {
		for (uint i = 0; i < substitutions.length; ++i) {
			uint[2] memory sub = substitutions[i][_variable];
			if (sub[1] != 0) {
				if (sub[0] == uint(Logic.TermKind.Number) || sub[0] == uint(Logic.TermKind.Literal))
					return sub;
				_variable = sub[1];
			}
		}
		return [uint(Logic.TermKind.Variable), _variable];
	}

	function freshVariableSymbol() internal returns (uint) {
		return currentFreshVariable++;
	}
}
