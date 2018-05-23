module algorithms.linear;

import std.typecons: Tuple;

import dataset: Key, Value, DataSet, notFound;

struct Set {
	private const Tuple!(Key, Value)[] arr;
	this (in DataSet dataset) {
		this.arr = dataset;
	}

	Value search(in Key key) const {
		for (size_t i = 0; i < arr.length; ++i) {
			if (arr[i][0] == key) return arr[i][1];
		}
		return notFound;
	}
}
unittest {
	import dataset: tiny;
	assert (Set(tiny).search(4L) == 5L);
	assert (Set(tiny).search(5L) == 1L);
	assert (Set(tiny).search(10L) == notFound);
}
