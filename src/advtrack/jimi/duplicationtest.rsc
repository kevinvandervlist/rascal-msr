module advtrack::jimi::duplicationtest

import IO;
import List;
import util::Math;
import util::ValueUI;

loc lipsum = |file:///home/jimi/UvA/Master/EvolutionSeries2/lipsum|;

public list[&T] shuffle(list[&T] l) =
    sort(l, bool(&T a, &T b) { return arbInt(1) == 1; });

public list[&T] shufflebad(list[&T] l) =
    sort(l, bool(_, _) { return arbInt(1) == 1; });

public test bool testtest(int clones) {
    lines = shuffle(readFileLines(lipsum));
    //lines = shufflebad(readFileLines(lipsum));
    text(lines);
    //println("A <a>, B <b>, C <c>");
    //println(l);
    return true;
}

public void main() {
    testtest(1);
}