module advtrack::kevin::Blocks

/**
 * Create a rel[location, string] from a dupdict.
 * So, a key with multiple locations results in a relation with the 
 * string given to each individual location
 * @param d A dupdict: {location}
 * @return rel[location, str] with all <location, str> tuples 
 */

private rel[location, str] createStringLocationRel(dupdict dup) {
	rel[location, str] ret = {};
	for(d <- dup) {
		ret += { < x, d> | x <- dup[d] };
	}
	return ret;
}

/**
 * Drop all lines from a rel[location, str] with <location, str> tuples, based on
 * parametrized blocksize and gap metrics. 
 * @param block The _minimum_ size of a block in lines.
 * @param gap The _maximum_ size of the gap between two elements to still be considered part of the same block.
 * @return rel[location, str] with all <location, str> tuples that conform to given constraints. 
 */
 
private list[tuple[location, str]] dropInvalidThreshold(int block, int gap, list[tuple[location l, str s]] lst) {
	rel[location, str] buf = {};
	list[tuple[location, str]] ret = [];
	
	// Set the current file
	location prev = head(lst).l;
	int block_size = 0;
		
	for(x <- lst) {
		// Same file, in block threshold?
		if(	(x.l.file == prev.file) &&
			((prev.line + gap) >= x.l.line)) {
			block_size += 1;
			buf += x;
		} else {
			// Different file, reset counter stuff and possibly add to ret
			if((buf != {}) && (block_size >= block)) {
				ret += sort(buf);
			}
			block_size = 0;
			buf = {};
		}
		// Set the previous location.
		prev = x.l;
	}
	
	// Add the current buffer if it is still within constraint boundaries
	if((buf != {}) && (block_size >= block)) {
		ret += sort(buf);
	}

	return ret;
}

/**
 * Create a list with all the blocks that validate given contraints 
 * @param block The _minimum_ size of a block in lines.
 * @param gap The _maximum_ size of the gap between two elements to still be considered part of the same block.
 * @return rel[location, str] with all <location, str> tuples 
 */

public list[tuple[location, str]] createBlockList(int block, int gap, dupdict dup) {
	l = createStringLocationRel(dup);
	sorted_l = sort(l);
	return dropInvalidThreshold(block, gap, sorted_l);
}
