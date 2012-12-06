module advtrack::kevin::Blocks

import advtrack::kevin::Dups;

import List;
import Set;
import IO;
import util::ValueUI;
import Exception;

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

public set[CFxy] matchFragments(list[CF] cl) {
	list[list[CFxy]] x = [matchPair(cla, clb) | cla <- cl, clb <- cl, cla != clb];
	set[CFxy] ret = {z | y <- x, z <- y};
	return ret;	
}




private list[CFxy] matchPair( CF a, CF b) {
	// Some temporary buffer structures
	list[set[int]] bufferA = [{}];
	list[set[int]] bufferB = [{}];
	set[int] buf = {};
	
	list[CFxy] ret = [];

	// Do this twice so all annotations are retained.
	intersectionA = a.lines & b.lines;
	//intersectionB = b.lines & a.lines;
	intersectionB = [x | x <- b.lines, x in intersectionA];
	
	if (size(intersectionA) < LINE_THRESHOLD) 
		return ret;
	
	// Get all the indexes of items in the above intersection
	//indexingA = [indexOf(a.lines, x) | x <- intersection];
	//indexingB = [indexOf(b.lines, x) | x <- intersection];
	indexingA = [x@linelocation.line | x <- intersectionA];
	indexingB = [x@linelocation.line | x <- intersectionB];

	// They can (and probably will be) a different size	
	sizeA = size(indexingA);
	sizeB = size(indexingB);
	
	indexingAsorted = sort(indexingA);
	indexingBsorted = sort(indexingB);
	
	// Now make sure we get chunks that are within the GAP_THRESHOLD
	for  (i <- [0..sizeA-2]) {
		if (indexingAsorted[i+1] - indexingAsorted[i] > GAP_THRESHOLD) {  			
			bufferA += buf;
			buf = {};
		} else {
			buf += {indexingAsorted[i+1], indexingAsorted[i]};
		}
	}
	bufferA += buf;
	buf = {};
		
	for  (i <- [0..sizeB-2]) {
		if (indexingBsorted[i+1] - indexingBsorted[i] > GAP_THRESHOLD) {  			
			bufferB += buf;
			buf = {};
		} else {
			buf += {indexingBsorted[i+1], indexingBsorted[i]};
		}
	}
	bufferB += buf;
	
	// Only retain buffers that are > LINE_THRESHOLD
	bufferA = [ x | x <- bufferA, size(x) >= LINE_THRESHOLD];
	bufferB = [ x | x <- bufferB, size(x) >= LINE_THRESHOLD];
	
	// No remaining buffers means no possible match.		
	if (size(bufferA) == 0 || size(bufferB) == 0)
		return ret;
	
	// Of each remaining buffer, create a list of the remaining lines in them, 
	// based on their location in the original list. 
	//sectionsA = [  [a.lines[f] |  f <- sort(toList(x))]  | x <-bufferA];
	//sectionsB = [  [b.lines[f] |  f <- sort(toList(x))]  | x <-bufferB];
	sectionsA = [  [getCodelineByLineNumber(a, f) |  f <- sort(toList(x))]  | x <-bufferA];
	sectionsB = [  [getCodelineByLineNumber(b, g) |  g <- sort(toList(y))]  | y <-bufferB];
	
	for(x <- sectionsA, 
		y <- sectionsB) {
		for ([_*, X*, _*] := x) { 
			for([_*, Y*, _*] := y) {
				if (X == Y && (size(X) >=  LINE_THRESHOLD)) {
					rx = CF(head(X)@linelocation.file, X);
					ry = CF(head(Y)@linelocation.file, Y);
					ret += [CFxy(rx, ry)];
				}
			}
		}
	}
	
	return ret;
}

private codeline getCodelineByLineNumber(CF x, int l) {
	r = [t | t <- x.lines, t@linelocation.line == l];
	if( r == []) {
		throw "L: <l> cannot be found in CF: \n<x>";
	} else {
		if(size(r) > 1)
			throw "WTF: Multiple occurences found.";
		return head(r);
	}
}






