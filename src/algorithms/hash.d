module algorithms.hash;

import dataset: Key, Value, DataSet, notFound;
import std.digest.sha: SHA256;
import std.typecons: Tuple;

enum tableSizeRatio = 1.4f;

size_t hash(in Key key, in size_t max) {
	immutable x = key;
	immutable y = (x ^ (x << 7));
	return (y ^ (y >> 9)) % max;
}

enum State {
	Empty,
	Value,
	Chain
}

struct ChainElm {
	State state = State.Empty;
	union {
		Tuple!(Key, Value) imm;
		Tuple!(Key, Value)[] chain;
	}
	Value get(in Key key) {
		final switch (state) {
		case State.Value:
			return imm[1];
		case State.Chain:
			foreach (pair; chain) {
				if (pair[0] == key) return pair[1];
			}	
			return notFound;
		case State.Empty:
			return notFound;
		}
	}
}

struct Chain {
	ChainElm[] table;
	this(in DataSet dataset) {
		table = new ChainElm[cast(ulong)(dataset.length * tableSizeRatio)];
		foreach (pair; dataset) {
			auto hashed = hash(pair[0], table.length);
			final switch (table[hashed].state) {
			case State.Empty:
				table[hashed].state = State.Value;
				table[hashed].imm = pair;
				break;
			case State.Value:
				table[hashed].state = State.Chain;
				table[hashed].chain = [table[hashed].imm, pair];
				break;
			case State.Chain:
				table[hashed].chain = table[hashed].chain ~ pair;
				break;
			}
		}
	}

	Value search(in Key key) {
		return table[hash(key, table.length)].get(key);
	}
}
unittest {
	import dataset: tiny;
	assert (Chain(tiny).search(4L) == 5L);
	assert (Chain(tiny).search(5L) == 1L);
}

struct OpenAddressElm {
	Key key;
	Value val;
	bool active;
}

import std.stdio;
struct OpenAddress {
	OpenAddressElm[] table;

	size_t rehash(in size_t n) {
		return (n + 1) % table.length;
	}

	this(in DataSet dataset) {
		table = new OpenAddressElm[cast(ulong)(dataset.length * tableSizeRatio)];
		foreach (pair; dataset) {
			auto hashed = hash(pair[0], table.length);
			while(table[hashed].active && table[hashed].key != pair[0]){
				hashed = rehash(hashed);
			}
			table[hashed] = OpenAddressElm(pair[0], pair[1], true);
		}
	}

	Value search(in Key key) {
		auto hashed = hash(key, table.length);
		while (true) {
			if (!table[hashed].active) return notFound;
			if (table[hashed].key == key) break;
			hashed = rehash(hashed);
		}
		return table[hashed].val;
	}
}
unittest {
	import dataset: tiny;
	assert (OpenAddress(tiny).search(4L) == 5L);
	assert (OpenAddress(tiny).search(5L) == 1L);
}
