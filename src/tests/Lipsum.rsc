module tests::Lipsum

import IO;
import List;
import util::Math;

private loc lipsumFile = |project://rascal-msr/data/lipsum|;
private list[str] lipsum = readFileLines(lipsumFile);
private int lipsumCounter = 0;

private loc muspilFile = |project://rascal-msr/data/muspil|;
private list[str] muspil = readFileLines(muspilFile);
private int muspilCounter = 0;


public list[&T] shuffle(list[&T] l) =
    sort(l, bool(&T a, &T b) { return arbInt(2) == 1; });

public list[str] getLipsum(int n) =
    slice(lipsum, 0, n);

public list[str] getLipsum(int s, int n) =
    slice(lipsum, s, n);

public list[str] getNextLipsum(int n) {
    slice(lipsum, lipsumCounter % size(lipsum), n);
    lipsumCounter += n;
}

public list[str] getShuffledLipsum(int n) =
    slice(shuffle(lipsum), 0, n);


public list[str] getNoise(int n) =
    slice(shuffle(muspil), 0, n);
    
public list[str] getNextNoise(int n) {
    if(muspilCounter + n > size(muspil) - 1)
        muspilCounter = 1;

    muspils = slice(muspil, muspilCounter, n);
    muspilCounter += n;
    return ["<muspilCounter>.<noise>" | noise <- muspils];
}
