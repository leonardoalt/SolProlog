pragma solidity >=0.5.8;

import './Unification.sol';

contract UnificationMock {
	mapping (uint => uint[2]) public substitutions;

	function unify(
		uint[2] memory _term1,
		uint[2][] memory _term1Args,
		uint[2] memory _term2,
		uint[2][] memory _term2Args
	) public returns (bool) {
		return Unification.unify(
			Logic.parseIntoTerm(_term1, _term1Args),
			Logic.parseIntoTerm(_term2, _term2Args),
			substitutions
		);
	}
}
