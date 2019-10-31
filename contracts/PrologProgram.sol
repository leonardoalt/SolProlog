pragma solidity >=0.5.8;
pragma experimental ABIEncoderV2;

import './Parser.sol';
import './Prolog.sol';

contract PrologProgram is Parser, Prolog {
	Logic.Term goal;

	function save(bytes memory _source) public {
		Parser.parse(_source);
	}

	function query(bytes memory _predicate) public returns (bool) {
		Parser.pos = 0;
		Parser.parsePredicate(_predicate, goal);
		Logic.Term[] memory goals = new Logic.Term[](1);
		goals[0] = goal;
		return Prolog.query(goals, rules);
	}
}
