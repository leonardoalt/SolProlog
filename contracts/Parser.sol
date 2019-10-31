pragma solidity >=0.5.8;
pragma experimental ABIEncoderV2;

import './Logic.sol';
import './Prolog.sol';

contract Parser {
	uint pos;
	uint constant zeroChar = 48;

	Prolog.Rule[] rules;

	function parse(bytes memory _source) public {
		parse(_source, rules);
	}

	function parse(bytes memory _source, Prolog.Rule[] storage _rules) internal {
		pos = 0;
		_rules.length = 0;
		while (pos < _source.length) {
			skipBlanks(_source);
			_rules.length++;
			parseRule(_source, _rules[_rules.length - 1]);
		}
	}

	function parseRule(bytes memory _source, Prolog.Rule storage _rule) internal {
		parsePredicate(_source, _rule.head);
		_rule.tail.length = 0;
		skipBlanks(_source);
		require(pos < _source.length, "Expected `.` or `:-`");
		if (_source[pos] == '.') {
			++pos;
			return;
		}
		require(
			_source[pos] == ':' &&
			++pos < _source.length &&
			_source[pos] == '-',
			"Expected `:-`."
		);
		do {
			++pos;
			skipBlanks(_source);
			_rule.tail.length++;
			parsePredicate(_source, _rule.tail[_rule.tail.length - 1]);
		} while (_source[pos] == ',');
		skipBlanks(_source);
		require(_source[pos++] == '.', "Expected `.`");
	}

	function parsePredicate(bytes memory _source, Logic.Term storage _term) internal {
		_term.kind = Logic.TermKind.Predicate;
		_term.arguments.length = 0;
		skipBlanks(_source);
		_term.symbol = parseLiteral(_source);
		require(_source[pos] == '(', error("Expected `(`, found ", _source[pos-1]));
		do {
			++pos;
			_term.arguments.length++;
			parseTerm(_source, _term.arguments[_term.arguments.length - 1]);
			skipBlanks(_source);
		} while (_source[pos] == ',');
		skipBlanks(_source);
		require(_source[pos++] == ')', error("Expected `)`, found ", _source[pos-1]));
	}

	function parseTerm(bytes memory _source, Logic.Term storage _term) internal {
		_term.arguments.length = 0;
		skipBlanks(_source);
		byte first = _source[pos];
		if (isDigit(first)) {
			_term.kind = Logic.TermKind.Number;
			_term.symbol = parseNumber(_source);
		}
		else if (isLowercase(first)) {
			_term.kind = Logic.TermKind.Literal;
			_term.symbol = parseLiteral(_source);
		}
		else if (isUppercase(first)) {
			_term.kind = Logic.TermKind.Variable;
			_term.symbol = parseLiteral(_source);
		}
		else
			revert("Expected number, literal or variable");
	}

	function parseNumber(bytes memory _source) internal pure returns (uint) {
		require(_source.length > 0, "Expected number.");
		uint p = _source.length - 1;
		uint acc = uint8(_source[p]) - zeroChar;
		if (p == 0)
			return acc;

		uint base = 10;
		while (true) {
			acc += base * (uint8(_source[--p]) - zeroChar);
			base *= 10;
			// TODO fix this, looks ugly
			if (p == 0)
				break;
		}
		return acc;
	}

	function parseLiteral(bytes memory _source) internal returns (uint) {
		uint identifier = 0;
		skipBlanks(_source);
		uint i = 0;
		while (i++ < 32 && pos < _source.length && isAlpha(_source[pos])) {
			identifier <<= 8;
			identifier |= uint8(_source[pos]);
			++pos;
		}
		require(i > 0 && i < 32, "Identifier must have at least one byte and cannot have more than 32 bytes");
		return identifier;
	}

	function skipBlanks(bytes memory _source) internal {
		while (pos < _source.length && isBlank(_source[pos]))
			++pos;
	}

	function isDigit(byte _char) internal pure returns (bool) {
		return _char >= '0' && _char <= '9';
	}

	function isAlpha(byte _char) internal pure returns (bool) {
		return isLowercase(_char) || isUppercase(_char);
	}

	function isLowercase(byte _char) internal pure returns (bool) {
		return _char >= 'a' && _char <= 'z';
	}

	function isUppercase(byte _char) internal pure returns (bool) {
		return _char >= 'A' && _char <= 'Z';
	}

	function isBlank(byte _char) internal pure returns (bool) {
		return _char == ' ' ||
			_char == '\t' ||
			_char == '\n';
	}

	function error(bytes memory _expected, byte _found) internal pure returns (string memory) {
		return string(abi.encodePacked(_expected, _found));
	}
}
