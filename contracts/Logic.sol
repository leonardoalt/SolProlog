pragma solidity >=0.5.8;

library Logic {
	struct Term {
		int symbol;
		Term[] arguments;
	}

	function isConstant(Term memory _term) internal pure returns (bool)  {
		return _term.arguments.length == 0 && _term.symbol > 0;
	}

	function isVariable(Term memory _term) internal pure returns (bool) {
		return _term.arguments.length == 0 && _term.symbol < 0;
	}

	function isPredicate(Term memory _term) internal pure returns (bool) {
		return _term.arguments.length > 0 && _term.symbol > 0;
	}

	function parseIntoTerm(int _term) internal pure returns (Term memory) {
		Term memory term;
		term.symbol = _term;
		return term;
	}

	function parseIntoTerm(int _term, int[] memory _arguments) internal pure returns (Term memory) {
		Term memory term;
		term.symbol = _term;
		if (_arguments.length > 0) {
			term.arguments = new Term[](_arguments.length);
			for (uint i = 0; i < _arguments.length; ++i)
				term.arguments[i].symbol = _arguments[i];
		}
		return term;
	}
}
