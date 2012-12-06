
module advtrack::kevin::Blocks

import advtrack::kevin::Dups;

import List;
import Set;
import IO;
import util::ValueUI;


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
		
	for(x <- lst) {
		// Same file, in block threshold?
		if(	(x.l.file == prev.file) &&
			((prev.line + gap) >= x.l.line)) {
			block_size += 1;
			buf += x;
		} else {
			// Different file or gap check failed, reset counter stuff and possibly add to ret
			if((buf != {}) && (block_size >= block)) {
				ret += [CF(prev.file, [ e | el <- sort(buf), e := codeline(el.s)[@linelocation=el.l]])];
			}
			block_size = 0;
			buf = {x};
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





public list[CFxy] matchFragments(list[CF] cl) {
	return [<cla, clb> | cla <- cl, clb <- cl, cla != clb, matchPair(cla, clb)];
}




private bool matchPair( CF a, CF b) {
	// Some temporary buffer structures
	list[set[int]] bufferA = [{}];
	list[set[int]] bufferB = [{}];
	set[int] buf = {};

	intersection = a.lines & b.lines;

	if (size(intersection) < LINE_THRESHOLD) 
		return false;
	
	// Get all the indexes of items in the above intersection
	indexingA = [indexOf(a.lines, x) | x <- intersection];
	indexingB = [indexOf(b.lines, x) | x <- intersection];
	
	
	sizeL = size(indexingA);
	indexingAsorted = sort(indexingA);
	indexingBsorted = sort(indexingB);
	
	// Now make sure we get chunks that are within the GAP_THRESHOLD
	for  (i <- [0..sizeL-2]) {
		if (indexingAsorted[i+1] - indexingAsorted[i] > GAP_THRESHOLD) {  			
			bufferA += buf;
			buf = {};
		} else {
			buf += {indexingAsorted[i+1], indexingAsorted[i]};
		}
	}
		
	for  (i <- [0..sizeL-2]) {
		if (indexingBsorted[i+1] - indexingBsorted[i] > GAP_THRESHOLD) {  			
			bufferB += buf;
			buf = {};
		} else {
			buf += {indexingBsorted[i+1], indexingBsorted[i]};
		}
	}
	
	// Only retain buffers that are > LINE_THRESHOLD
	bufferA = [ x | x <- bufferA, size(x) >= LINE_THRESHOLD];
	bufferB = [ x | x <- bufferB, size(x) >= LINE_THRESHOLD];		

	// No remaining buffers means no possible match.		
	if (size(bufferA) == 0 || size(bufferB) == 0)
		return false;
	
	// Of each remaining buffer, create a list of the remaining lines in them, 
	// based on their location in the original list. 
	sectionsA = [  [a.lines[f] |  f <- sort(toList(x))]  | x <-bufferA];
	sectionsB = [  [b.lines[f] |  f <- sort(toList(x))]  | x <-bufferB];
		
	list[codeline] prev = [];
	
	println(sectionsA);
	
	/*
	for (x <- sectionsA) {
		for (y <- sectionsB) {
			for ( [_*, X*, _*] := x) {
				for ( [_*, Y*, _*] := y) {
					if (X == Y &&  (size(X) >=  LINE_THRESHOLD)) {
						if (!(prev < X)) {
							println(X);
						} 
						prev = X;
						
					}
				}
			}
		}
	}
	*/	 
	return true;
}








