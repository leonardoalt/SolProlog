pragma solidity >=0.5.8;

library Logic {
	enum TermKind {
		Number,
		Literal,
		Variable,
		Predicate
	}

	struct Term {
		TermKind kind;
		uint symbol;
		Term[] arguments;
	}

	function parseIntoTerm(uint[2] memory _term) internal pure returns (Term memory) {
		Term memory term;
		term.kind = TermKind(_term[0]);
		term.symbol = _term[1];
		return term;
	}

	function parseIntoTerm(uint[2] memory _term, uint[2][] memory _arguments) internal pure returns (Term memory) {
		Term memory term;
		term.kind = TermKind(_term[0]);
		term.symbol = _term[1];
		if (_arguments.length > 0) {
			term.arguments = new Term[](_arguments.length);
			for (uint i = 0; i < _arguments.length; ++i) {
				term.arguments[i].kind = TermKind(_arguments[i][0]);
				term.arguments[i].symbol = _arguments[i][1];
			}
		}
		return term;
	}
}
