module algorithms.binary;

import std.typecons: Tuple;
import std.algorithm.sorting: sort;
import std.range : array;

import dataset: Key, Value, DataSet, notFound;

struct Set {
	private const Tuple!(Key, Value)[] arr;
	this (in DataSet dataset) {
		this.arr = dataset.dup.sort!((a, b) => a[0] < b[0]).array;
	}

	Value search(in Key key) const {
		size_t begin, end=arr.length;
		for(;;) {
			auto sep = (begin+end)/2;
			if (arr[sep][0] == key) return arr[sep][1];
			if (arr[sep][0] > key) {
				end = sep;
			}
			else {
				begin = sep+1;
			}
			if (begin == end) break;
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
