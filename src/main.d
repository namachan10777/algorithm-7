import std.stdio;
import std.typecons;
import std.datetime.stopwatch;
import dataset;
import algorithms.linear;
import algorithms.tree;
import algorithms.hash;

enum MeasureTimeMax = 10;

alias time_t = double;

auto measure(S, alias samplingInterval)(S set, size_t n) {
	StopWatch sw;
	time_t min = time_t.max;
	time_t max = 0;
	time_t total = 0;
	size_t cnt;
	for (size_t i = 0; i < n; i += (i/samplingInterval > 0 ? i/samplingInterval : 1)) {
		++cnt;
		sw.start;
		set.search(i);
		sw.stop;
		auto t = sw.peek.total!"nsecs";
		min = t < min ? t : min;
		max = t > max ? t : max;
		total += t;
		sw.reset;
	}
	return tuple(total/cnt, min, max);
}

alias Time = Tuple!(time_t, time_t, time_t);
struct Column(alias len) {
	size_t n;
	Time[len] times;
}
alias Table(alias n)  = Column!(n)[];

import std.stdio;

Table!(Ss.length) makeLog(Ss...)(in size_t interval, in size_t timeLimit, in size_t nLimit) {
	Column!(Ss.length)[] tbl;
	StopWatch totalTime;
	totalTime.start;
	for (size_t n = 1;n < nLimit; n+=interval) {
		stderr.writef!"measure for n=%s "(n);
		auto dataset = mkdataset(n);
		size_t id;
		Column!(Ss.length) col;
		col.n = n;
		tbl ~= col;
		static foreach(S; Ss) {{
			stderr.writef!"%s "(S.stringof);
			auto set = S(dataset);
			time_t min = 0, max = 0, mean = 0;
			StopWatch measuringTime;
			measuringTime.start;
			size_t m = 0;
			for (;;) {
				++m;
				auto result = measure!(S, 100)(set, n);
				mean += result[0];
				min  += result[1];
				max  += result[2];
				if (measuringTime.peek.total!"msecs" > 100) break;
			}
			tbl[$-1].times[id++] = tuple(mean/m, min/m, max/m);
		}}
		stderr.writeln;
		if (totalTime.peek.total!"seconds" > timeLimit) break;
	}
	return tbl;
}

string generatePlotScript(Ss...)(in string[string] typeNameToLegend, in string csvName, in string figName) {
	import std.format;
	string commands = format!"plot \"%s\" using 1:2 w l title \"%s\"\n"(csvName, typeNameToLegend[Ss[0].stringof]);
	static foreach (i, S; Ss[1..$]) {
		commands ~=
			format!"replot \"%s\" using 1:%s w l title \"%s\"\n"(csvName, i+3, typeNameToLegend[S.stringof]);
	}
	enum base =
q{
set datafile separator ","
set xl "dataset size"
set yl "nsecs"
%s
set terminal pdf
set out "%s"
replot
};
	return format!base(commands, figName);
}

void writePlotScripts(Ss...)(in string[string] typeNameToLegend, in string base) {
	File(base~"-min.script", "w").write(generatePlotScript!Ss(typeNameToLegend, base~"-min.csv", base~"-min.pdf"));
	File(base~"-max.script", "w").write(generatePlotScript!Ss(typeNameToLegend, base~"-max.csv", base~"-max.pdf"));
	File(base~"-mean.script", "w").write(generatePlotScript!Ss(typeNameToLegend, base~"-mean.csv", base~"-mean.pdf"));
}

void flushLog(T: Column!(len)[], alias len)(in T tbl, in string baseName) {
	auto meanF = File(baseName~"-mean.csv", "w");
	auto minF = File(baseName~"-min.csv", "w");
	auto maxF = File(baseName~"-max.csv", "w");
	foreach (col; tbl) {
		meanF.writef!"%s,"(col.n);
		minF.writef!"%s,"(col.n);
		maxF.writef!"%s,"(col.n);
		foreach (time; col.times) {
			meanF.writef!" %s,"(time[0]);
			minF.writef!" %s,"(time[1]);
			maxF.writef!" %s,"(time[2]);
		}
		meanF.writeln;
		minF.writeln;
		maxF.writeln;
	}
}

void main() {
	import std.meta;
	auto map = [
		"Line": "line",
		"Sentinel": "line(sentinel)",
		"Binary": "binary search",
		"Wfs": "WFS",
		"Dfs": "DFS",
		"Chain": "hash(chain)",
		"OpenAddress": "hash(open address"
	];
	alias AllSet = AliasSeq!(Line, Sentinel, Binary, Wfs, Dfs, Chain, OpenAddress);
	makeLog!AllSet(100, 1200, 15000).flushLog("all");
	writePlotScripts!AllSet(map, "all");

	alias LineHash = AliasSeq!(Line, Sentinel, Binary, Chain, OpenAddress);
	makeLog!LineHash(50, 600, 15000).flushLog("line-hash");
	writePlotScripts!LineHash(map, "line-hash");

	alias BinaryHash = AliasSeq!(Binary, Chain, OpenAddress);
	makeLog!BinaryHash(50, 600, 15000).flushLog("binary-hash");
	writePlotScripts!BinaryHash(map, "binary-hash");
}
