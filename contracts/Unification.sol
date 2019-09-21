pragma solidity >=0.5.8;

import './Logic.sol';

library Unification {
	function unify(Logic.Term memory _term1, Logic.Term memory _term2, mapping (uint => uint[2]) storage _substitutions) internal returns (bool) {
		if (_term1.arguments.length != _term2.arguments.length)
			return false;

		if (_term1.kind == Logic.TermKind.Predicate) {
			assert(_term2.kind == Logic.TermKind.Predicate);
			return unifyPredicates(_term1, _term2, _substitutions);
		}

		if (_term1.kind == _term2.kind && _term1.symbol == _term2.symbol)
			return true;

		if (_term1.kind == Logic.TermKind.Number && _term2.kind == Logic.TermKind.Number)
			return false;

		if (_term1.kind == Logic.TermKind.Literal && _term2.kind == Logic.TermKind.Literal)
			return false;

		if (_term1.kind != Logic.TermKind.Variable && _term2.kind == Logic.TermKind.Variable)
			return unify(_term2, _term1, _substitutions);

		assert(_term1.kind == Logic.TermKind.Variable);

		if (_term2.kind == Logic.TermKind.Predicate)
			return false;

		_substitutions[_term1.symbol] = [uint(_term2.kind), _term2.symbol];

		return true;
	}

	function unifyPredicates(Logic.Term memory _term1, Logic.Term memory _term2, mapping (uint => uint[2]) storage _substitutions) internal returns (bool) {
		require(_term1.kind == Logic.TermKind.Predicate && _term2.kind == Logic.TermKind.Predicate);

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
