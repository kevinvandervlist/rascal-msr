module advtrack::kevin::Evolution::Compare

import advtrack::Constants;
import advtrack::Datatypes;
import advtrack::kevin::Util;

import IO;
import List;

public void main() {
	if(!exists(GENDUMP_LOC)) {
		println("No dump found at <dump>. Try to run getCCCloneSectionsOverTime() from advtrack::kevin::Detection::Dups.");
		return;
	}
	
	list[Generation] gens = readGenerationsFromFile(GENDUMP_LOC);
	
	list[tuple[Generation x, Generation y] pair] genpairs = getGenerationTuples(gens);
}

private list[tuple[Generation, Generation]] getGenerationTuples(list[Generation] gens) {
	list[tuple[Generation, Generation]] ret = [];
	for(x <- [0..size(gens) - 2]) {
		ret += <gens[x], gens[x+1]>;
	}
	return ret;
}