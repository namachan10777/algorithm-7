module algorithms.dfs;

import std.typecons : Tuple, tuple;

import dataset: Key, Value, DataSet, notFound;

class Node {
	Key key;
	Value val;
	Node right, left;
	this(in Key key, in Value val, Node left, Node right) {
		this.key = key;
		this.val = val;
		this.left = left;
		this.right = right;
	}
}

Node makeTree(DataSet dataset) {
	if (dataset.length == 0) return null;
	auto sep = dataset.length/2;
	return new Node(dataset[sep][0], dataset[sep][1],
		makeTree(dataset[0..sep]),
		makeTree(dataset[sep+1..$]));
}

Value dfs_impl(in Node tree, in Key key) {
	if (tree is null) return notFound;
	if (tree.key == key) return tree.val;
	auto l = dfs_impl(tree.left, key);
	if (l != notFound) return l;
	auto r = dfs_impl(tree.right, key);
	if (r != notFound) return r;
	return notFound;
}

Value wfs_impl(Node tree, in size_t size, in Key key) {
	auto queue = new Node[size];
	queue[0] = tree;
	size_t begin, end=1;
	for (;begin < size; ++begin){
		if (queue[begin].key == key) return queue[begin].val;
		if (queue[begin].left !is null) {
			queue[end++] = queue[begin].left;
		}
		if (queue[begin].right !is null) {
			queue[end++] = queue[begin].right;
		}
	}
	return notFound;
}

struct Set {
	Node tree;
	size_t size;
	this (DataSet dataset) {
		this.tree = makeTree(dataset);
		this.size = dataset.length;
	}

	Value dfs(in Key key) {
		return dfs_impl(this.tree, key);
	}

	Value wfs(in Key key) {
		return wfs_impl(this.tree, this.size, key);
	}
}
unittest {
	import dataset: tiny;
	assert (Set(tiny).dfs(4L) == 5L);
	assert (Set(tiny).dfs(5L) == 1L);
	assert (Set(tiny).dfs(10L) == notFound);
	assert (Set(tiny).wfs(4L) == 5L);
	assert (Set(tiny).wfs(5L) == 1L);
	assert (Set(tiny).wfs(10L) == notFound);
}
