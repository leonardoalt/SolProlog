pragma solidity >=0.5.8;

import './Logic.sol';

contract LogicMock {
	function isNumber(uint[2] memory _term) public pure returns (bool) {
		return Logic.parseIntoTerm(_term).kind == Logic.TermKind.Number;
	}

	function isLiteral(uint[2] memory _term) public pure returns (bool) {
		return Logic.parseIntoTerm(_term).kind == Logic.TermKind.Literal;
	}

	function isVariable(uint[2] memory _term) public pure returns (bool) {
		return Logic.parseIntoTerm(_term).kind == Logic.TermKind.Variable;
	}
	
	function isPredicate(uint[2] memory _term, uint[2][] memory _arguments) public pure returns (bool) {
		return Logic.parseIntoTerm(_term, _arguments).kind == Logic.TermKind.Predicate;
	}
}
