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

	int cmp = 85;
	
	set[CFxy] pairs = {};
	
	// List intersections
	for(x <- cflist, y <- cflist) {
		/*
		i = x.lines & y.lines;
		
		match = toReal(size(i)) / toReal(size(x.lines)) * 100;
		if((match > cmp) && (x != y)) {
			pairs += {CFxy(x, y)};
		} 
		*/
	}
	
	for(p <- pairs) {
		linesx = [x@linelocation.line| x <- p.x.lines];
		linesy = [y@linelocation.line| y <- p.y.lines];
		
		i = p.x.lines & p.y.lines;
		println("Pair(<size(i)>): <p.x.file>[<linesx>]:<p.y.file>[<linesy>]");
	}

	return cflist;
}


