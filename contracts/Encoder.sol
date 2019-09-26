pragma solidity >=0.5.8;
pragma experimental ABIEncoderV2;

import './Logic.sol';
import './Prolog.sol';

library Encoder {
	function encodeRules(Prolog.Rule[] storage _rules) public view returns (uint[][][] memory) {
		uint[][][] memory encoded = new uint[][][](_rules.length);
		for (uint i = 0; i < _rules.length; ++i)
			encoded[i] = encodeRule(_rules[i]);
		return encoded;
	}

	function encodeRule(Prolog.Rule storage _rule) internal view returns (uint[][] memory) {
		uint[][] memory rule = new uint[][](1 + _rule.tail.length);
		rule[0] = encodePredicate(_rule.head);
		for (uint i = 0; i < _rule.tail.length; ++i)
			rule[i + 1] = encodePredicate(_rule.tail[i]);
		return rule;
	}

	function encodePredicate(Logic.Term storage _term) internal view returns (uint[] memory) {
		uint[] memory term = new uint[](1 + (2 * (1 + _term.arguments.length)));
		(term[0], term[1]) = encodeSimpleTerm(_term);
		term[2] = _term.arguments.length;
		for (uint i = 0; i < _term.arguments.length; ++i)
			(term[i + 3], term[i + 4]) = encodeSimpleTerm(_term.arguments[i]);
		return term;
	}

	function encodeSimpleTerm(Logic.Term storage _term) internal view returns (uint, uint) {
		return (uint(_term.kind), _term.symbol);
	}
}
