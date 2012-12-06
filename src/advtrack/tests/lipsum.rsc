module advtrack::tests::lipsum

import IO;
import List;
import util::Math;
import util::ValueUI;


private loc lipsumFile = |file:///home/jimi/UvA/Master/EvolutionSeries2/lipsum|;
private list[str] lipsum = readFileLines(lipsumFile);
private int lipsumCounter = 0;

private loc muspilFile = |file:///home/jimi/UvA/Master/EvolutionSeries2/muspil|;
private list[str] muspil = readFileLines(muspilFile);
private int muspilCounter = 0;


public list[&T] shuffle(list[&T] l) =
    sort(l, bool(&T a, &T b) { return arbInt(2) == 1; });


public list[str] get(int n) =
    slice(lipsum, 0, n);

public list[str] get(int s, int n) =
    slice(lipsum, s, n);

public list[str] getNext(int n) {
    slice(lipsum, lipsumCounter % size(lipsum), n);
    lipsumCounter += n;
}

public list[str] getShuffled(int n) =
    slice(shuffle(lipsum), 0, n);


public list[str] getNoise(int n) =
    slice(shuffle(muspil), 0, n);

public list[str] getNextNoise(int n) {
    slice(muspil, muspilCounter % size(muspil), n);
    muspilCounter += n;
} 
