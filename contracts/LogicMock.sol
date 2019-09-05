pragma solidity >=0.5.8;

import './Logic.sol';

contract LogicMock {
	function isConstant(int _term) public pure returns (bool) {
		return Logic.isConstant(Logic.parseIntoTerm(_term));
	}

	function isVariable(int _term) public pure returns (bool) {
		return Logic.isVariable(Logic.parseIntoTerm(_term));
	}
	
	function isPredicate(int _term, int[] memory _arguments) public pure returns (bool) {
		return Logic.isPredicate(Logic.parseIntoTerm(_term, _arguments));
	}
}
