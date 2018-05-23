module algorithms.linear_sentinel;

import std.typecons: Tuple, tuple;

import dataset: Key, Value, DataSet, notFound;

struct Set {
	private Tuple!(Key, Value)[] arr;
	this (in DataSet dataset) {
		//番兵用の領域を確保
		this.arr = dataset.dup ~ [tuple(0L, notFound)];
	}

	Value search(in Key key) {
		arr[$-1] = tuple(key, notFound);
		for (size_t i = 0;; ++i) {
			if (arr[i][0] == key) return arr[i][1];
		}
	}
}
unittest {
	import dataset: tiny;
	assert (Set(tiny).search(4L) == 5L);
	assert (Set(tiny).search(5L) == 1L);
	assert (Set(tiny).search(10L) == notFound);
}
