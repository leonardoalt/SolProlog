pragma solidity >=0.5.8;

import './Logic.sol';

library Unification {
	function unify(Logic.Term memory _term1, Logic.Term memory _term2, mapping (int => int) storage _substitutions) internal returns (bool) {
		if (_term1.arguments.length != _term2.arguments.length)
			return false;

		if (Logic.isPredicate(_term1)) {
			assert(Logic.isPredicate(_term2));
			return unifyPredicates(_term1, _term2, _substitutions);
		}

		if (_term1.symbol == _term2.symbol)
			return true;

		if (Logic.isConstant(_term1) && Logic.isConstant(_term2))
			return false;

		if (!Logic.isVariable(_term1) && Logic.isVariable(_term2))
			return unify(_term2, _term1, _substitutions);

		assert(Logic.isVariable(_term1));

		if (Logic.isPredicate(_term2))
			return false;

		_substitutions[_term1.symbol] = _term2.symbol;

		return true;
	}

	function unifyPredicates(Logic.Term memory _term1, Logic.Term memory _term2, mapping (int => int) storage _substitutions) internal returns (bool) {
		require(Logic.isPredicate(_term1) && Logic.isPredicate(_term2));

		if (_term1.symbol != _term2.symbol)
			return false;

		if (_term1.arguments.length != _term2.arguments.length)
			return false;

		for (uint i = 0; i < _term1.arguments.length; ++i)
			if (!unify(_term1.arguments[i], _term2.arguments[i], _substitutions))
				return false;

		return true;
	}
}
