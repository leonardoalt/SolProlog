pragma solidity >=0.5.8;

import './Unification.sol';

contract UnificationMock {
	function unify(
		int _term1,
		int[] memory _term1Args,
		int _term2,
		int[] memory _term2Args
	) public pure returns (bool) {
		return Unification.unify(
			Logic.parseIntoTerm(_term1, _term1Args),
			Logic.parseIntoTerm(_term2, _term2Args)
		);
	}
}
