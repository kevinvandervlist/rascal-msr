module advtrack::tests::lipsum

import IO;
import List;
import util::Math;
import util::ValueUI;

loc lipsumFile = |file:///home/jimi/UvA/Master/EvolutionSeries2/lipsum|;
list[str] lipsum = readFileLines(lipsumFile);

loc muspilFile = |file:///home/jimi/UvA/Master/EvolutionSeries2/muspil|;
list[str] muspil = readFileLines(muspilFile);

public list[&T] shuffle(list[&T] l) =
    sort(l, bool(&T a, &T b) { return arbInt(2) == 1; });

public list[str] get(int n) =
    slice(lipsum, 0, n);

public list[str] getShuffled(int n) =
    slice(shuffle(lipsum), 0, n);

public list[str] getNoise(int n) =
    slice(shuffle(muspil), 0, n);
