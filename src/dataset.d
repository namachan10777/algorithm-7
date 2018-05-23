module dataset;

import std.typecons;

alias Key = long;
alias Value = long;

Value notFound = -1;

alias DataSet = Tuple!(Key, Value)[];

DataSet tiny = [
	tuple(5L, 1L),
	tuple(9L, 2L),
	tuple(6L, 3L),
	tuple(1L, 4L),
	tuple(4L, 5L),
	tuple(8L, 6L),
	tuple(7L, 7L),
	tuple(3L, 8L),
	tuple(2L, 9L),
];
