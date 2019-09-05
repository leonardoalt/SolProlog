# SolProlog

This repository contains a simple Prolog backend implementation in Solidity.

### Encoding

The libraries take the goals and rules encoded as `Terms`, where a `Term` has
an integer `symbol` and a list of children `Terms`, its `arguments`.
Constants are encoded as positive numbers, and variables as negative numbers.
The number 0 is not used.

It's the responsibility of the caller to make sure that the goals and rules are
encoded correctly, since there are several possible ways to encode a Prolog program
into this format.

As an example, take the rules
```
mother(gertrud, tanja).
mother(tanja, zelda).
grandmother(X, Y):- mother(X, Z), mother(Z, Y).
```
and goal `grandmother(gertrud, N)`.

The constants are mother, gertrud, tanja, zelda, grandmother.
The variables are X, Y, Z.
A parser suggestion would simply enumerate those in the same order as they are
seen, leading to rules
```
1 [2, 3].
1 [3, 4].
5 [-1, -2]:- 1 [-1, -3],  1 [-3, -2].
```
and goal `5 [2, -4]`.

The resulting substitutions are given using the same encoding, and the caller must
map those back to the original source.

### Prolog Support

So far lists, disjunctions, nested predicates and metapredicates are not supported.