module advtrack::kevin::Evolution::Compare

import advtrack::Constants;
import advtrack::Datatypes;
import advtrack::kevin::Util;

import IO;
import List;

public void main() {
	loc f = GENDUMP_LOC;
	if(!exists(f)) {
		println("No dump found at <f>. ");
		println("Try to run getCCCloneSectionsOverTime() from advtrack::kevin::Detection::Dups.");
		return;
	}
	
	list[Generation] gens = readGenerationsFromFile(GENDUMP_LOC);
	
	list[tuple[Generation x, Generation y]] genpairs = getGenerationTuples(gens);
	for(g <- genpairs) {
		;
	}
}

private list[tuple[Generation, Generation]] getGenerationTuples(list[Generation] gens) {
	list[tuple[Generation, Generation]] ret = [];
	for(x <- [0..size(gens) - 2]) {
		ret += <gens[x], gens[x+1]>;
	}
	return ret;
}