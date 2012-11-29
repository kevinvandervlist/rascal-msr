module advtrack::kevin::CodeFragments

import List;
import Set;

import advtrack::kevin::Blocks;

import advtrack::Datatypes;

import IO;

public list[CF] createCodeFragments(int block, int gap, dupdict dup) {
	// Step one: initial cf's.
	cflist = createFirstStepCodeFragments(block, gap, dup);
	
	// Diff all lists with each other.
	for(x <- cflist, y <- cflist) {
		println("Diff: <x.lines - y.lines>");
	} 
	return cflist;
}


