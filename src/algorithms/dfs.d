module algorithms.bintree.common;

import std.typecons : Tuple, tuple;

import dataset: Key, Value, DataSet, notFound;

//datasetをDFSの探索順にソートする事で、線形探索でDFS出来る
DataSet makeTree(in DataSet dataset) {
	auto tree = new Tuple!(Key, Value)[dataset.length];
	auto flags = new bool[dataset.length];
	size_t cnt;
	void f (in size_t begin, in size_t end) {
		import std.stdio;
		auto sep = (begin + end) / 2;

		if (begin == end) return;
		tree[cnt++] = dataset[sep];
		f (begin, sep);
		f (sep+1, end);
	}
	f (0, dataset.length);
	return tree;
}

struct Set {
	DataSet arr;
	this (in DataSet dataset) {
		this.arr = makeTree(dataset) ~ [tuple(0L, 0L)];
	}

	Value search(in Key key) {
		arr[$-1] = tuple(key, notFound);
		for (size_t i;; ++i) {
			if (arr[i][0] == key) return arr[i][1];
		}
	}
}
unittest {
	import dataset: tiny;
	import std.stdio;
	alias t = tuple!(long, long);
	assert (Set(tiny).arr == [t(4,5), t(6,3), t(9,2), t(5,1), t(1,4), t(3,8), t(7,7), t(8,6), t(2,9), t(0,0)]);
	assert (Set(tiny).search(4L) == 5L);
	assert (Set(tiny).search(5L) == 1L);
	assert (Set(tiny).search(10L) == notFound);
}
