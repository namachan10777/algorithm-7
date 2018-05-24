module algorithms.hash;

import dataset: Key, Value, DataSet, notFound;
import std.digest.sha: SHA256;
import std.typecons: Tuple;

union Seed {
	Key key;
	ubyte[Key.sizeof] seeds;
}

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

struct Cont {
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
	Cont[] conts;
	this(in DataSet dataset) {
		conts = new Cont[dataset.length];
		foreach (pair; dataset) {
			auto hashed = hash(pair[0], dataset.length);
			final switch (conts[hashed].state) {
			case State.Empty:
				conts[hashed].state = State.Value;
				conts[hashed].imm = pair;
				break;
			case State.Value:
				conts[hashed].state = State.Chain;
				conts[hashed].chain = [conts[hashed].imm, pair];
				break;
			case State.Chain:
				conts[hashed].chain = conts[hashed].chain ~ pair;
				break;
			}
		}
	}

	Value search(in Key key) {
		return conts[hash(key, conts.length)].get(key);
	}
}
unittest {
	import dataset: tiny;
	assert (Chain(tiny).search(4L) == 5L);
	assert (Chain(tiny).search(5L) == 1L);
}
