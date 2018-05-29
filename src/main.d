import std.stdio;
import std.typecons;
import std.datetime.stopwatch;
import dataset;
import algorithms.linear;
import algorithms.tree;
import algorithms.hash;

enum MeasureTimeMax = 10;

auto measure(S)(S set, size_t n) {
	StopWatch sw;
	size_t min = size_t.max;
	size_t max = 0;
	size_t total = 0;
	for (size_t i = 0; i < n; ++i) {
		sw.start;
		set.search(i);
		sw.stop;
		auto t = sw.peek.total!"nsecs";
		min = t < min ? t : min;
		max = t > max ? t : max;
		total += t;
		sw.reset;
	}
	return tuple(total/n, min, max);
}

void main() {
	StopWatch totalTimeCounter;
	StopWatch sw;
	auto minFile = File("min.csv", "w");
	auto maxFile = File("max.csv", "w");
	auto meanFile = File("mean.csv", "w");
	import std.stdio;
	for (float x = 1;; x *= 1.1f) {
		size_t n = cast(size_t)x;
		totalTimeCounter.start;
		auto dataset = mkdataset(n);

		auto line = Line(dataset);
		auto sentinel = Sentinel(dataset);
		auto binary = Binary(dataset);
		auto dfs = Dfs(dataset);
		auto wfs = Wfs(dataset);
		auto chain = Chain(dataset);
		auto openaddress = OpenAddress(dataset);

		auto lineT = measure!Line(line, n);
		auto sentinelT = measure!Sentinel(sentinel, n);
		auto binaryT = measure!Binary(binary, n);
		auto dfsT = measure!Dfs(dfs, n);
		auto wfsT = measure!Wfs(wfs, n);
		auto chainT = measure!Chain(chain, n);
		auto openaddressT = measure!OpenAddress(openaddress, n);

		meanFile.writefln!"%s, %s, %s, %s, %s, %s, %s, %s"(n, lineT[0], sentinelT[0], binaryT[0], dfsT[0], wfsT[0], chainT[0], openaddressT[0]);
		minFile.writefln!"%s, %s, %s, %s, %s, %s, %s, %s"(n, lineT[1], sentinelT[1], binaryT[1], dfsT[1], wfsT[0], chainT[1], openaddressT[1]);
		maxFile.writefln!"%s, %s, %s, %s, %s, %s, %s, %s"(n, lineT[2], sentinelT[2], binaryT[2], dfsT[2], wfsT[0], chainT[2], openaddressT[2]);

		totalTimeCounter.stop;
		if (totalTimeCounter.peek.total!"seconds" > 10) break;
		totalTimeCounter.reset;
	}
}
