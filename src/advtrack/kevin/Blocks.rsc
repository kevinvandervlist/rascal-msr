
module advtrack::kevin::Blocks

import List;
import Set;

import advtrack::Datatypes;

alias dupdict = map[str line, set[location] locs];

/**
 * Create a rel[location, string] from a dupdict.
 * So, a key with multiple locations results in a relation with the 
 * string given to each individual location
 * @param d A dupdict: {location}
 * @return rel[location, str] with all <location, str> tuples 
 */

private rel[location, str] createStringLocationRel(dupdict dup) {
	return { < x, d> | d <- dup, x <- dup[d] };
}

/**
 * Drop all lines from a rel[location, str] with <location, str> tuples, based on
 * parametrized blocksize and gap metrics. 
 * @param block The _minimum_ size of a block in lines.
 * @param gap The _maximum_ size of the gap between two elements to still be considered part of the same block.
 * @return rel[location, str] with all <location, str> tuples that conform to given constraints. 
 */
 
private list[CF] dropInvalidThreshold(int block, int gap, list[tuple[location l, str s]] lst) {
	rel[location l, str s] buf = {};
	list[CF] ret = [];
	
	// Set the current file
	location prev = head(lst).l;
	int block_size = 0;
	int cgap = gap;
		
	for(x <- lst) {
		// Same file, in block threshold?
		if(	(x.l.file == prev.file) &&
			((prev.line + cgap) >= x.l.line)) {
			if((prev.line + 1) != x.l.line) {
				cgap -= 1;
			}
			block_size += 1;
			buf += x;
		} else {
			// Different file or gap check failed, reset counter stuff and possibly add to ret
			if((buf != {}) && (block_size >= block)) {
				ret += [CF(prev.file, [ e | el <- sort(buf), e := codeline(el.s)[@linelocation=el.l]])];
			}
			block_size = 0;
			buf = {x};
			cgap = gap;
		}
		// Set the previous location.
		prev = x.l;
	}
	
	// Add the current buffer if it is still within constraint boundaries
	if((buf != {}) && (block_size >= block)) {
		ret += [CF(prev.file, [ e | el <- sort(buf), e := codeline(el.s)[@linelocation=el.l]])];
	}

	return ret;
}

/**
 * Create a list of CFs that validate given constraints.
 * This is the first step.
 * @param block The _minimum_ size of a block in lines.
 * @param gap The _maximum_ size of the gap between two elements to 
 * still be considered part of the same block.
 * @return rel[location, str] with all <location, str> tuples 
 */

public list[CF] createFirstStepCodeFragments(int block, int gap, dupdict dup) {
	l = createStringLocationRel(dup);
	return dropInvalidThreshold(block, gap, sort(l));
}
