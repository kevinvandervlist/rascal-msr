module advtrack::kevin::CodeFragments

import List;
import Set;

import advtrack::kevin::Blocks;

import advtrack::Datatypes;

import IO;

public list[CF] createCodeFragments(int block, int gap, dupdict dup) {
	// Step one: initial cf's.
	cflist = createFirstStepCodeFragments(block, gap, dup);
	return cflist;
}

private list[CF] createInitialCFList(list[codeline] cl) {
	//location(loc file, int line);
	//codeline(str line, location linelocation);
	//CF(loc file, list[codeline] lines);
}