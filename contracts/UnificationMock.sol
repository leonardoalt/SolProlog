pragma solidity >=0.5.8;

import './Unification.sol';

contract UnificationMock {
	mapping (int => int) public substitutions;

	function unify(
		int _term1,
		int[] memory _term1Args,
		int _term2,
		int[] memory _term2Args
	) public returns (bool) {
		return Unification.unify(
			Logic.parseIntoTerm(_term1, _term1Args),
			Logic.parseIntoTerm(_term2, _term2Args),
			substitutions
		);
	}
}
