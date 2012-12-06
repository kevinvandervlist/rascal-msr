module advtrack::kevin::CodeFragments

import List;
import Set;
import util::Math;
import util::ValueUI;

import advtrack::kevin::Blocks;

import advtrack::Datatypes;

import IO;

public list[CF] createCodeFragments(int block, int gap, dupdict dup) {
	// Step one: initial cf's.
	cflist = createFirstStepCodeFragments(block, gap, dup);

	return cflist;
}


