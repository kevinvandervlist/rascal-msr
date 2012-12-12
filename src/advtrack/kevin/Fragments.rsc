module advtrack::kevin::Fragments

import List;
import Set;
import util::Math;
import util::ValueUI;

import advtrack::kevin::Dups;
import advtrack::Datatypes;
import advtrack::Constants;

import IO;


alias dupdict = map[str line, set[location] locs];

/**
 * Create a list of CFs that validate given constraints.
 * This is the first step.
 * @param block The _minimum_ size of a block in lines.
 * @param gap The _maximum_ size of the gap between two elements to 
 * still be considered part of the same block.
 * @return rel[location, str] with all <location, str> tuples 
 */
public list[CF] createCodeFragments(dupdict dup) {
	// Step one: initial cf's.
	locationRelation = createStringLocationRel(dup);
	return dropInvalidThreshold(sort(locationRelation));
	
}


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
 
public  list[CF] dropInvalidThreshold(list[tuple[location l, str s]] lst) {
	rel[location l, str s] buf = {};
	list[CF] ret = [];
	
	// Set the current file
	location prev = head(lst).l;
	int block_size = 0;
		
	for(x <- lst) {
		// Same file, in block threshold?
		if(	(x.l.file == prev.file) &&
			((prev.line + GAP_SIZE) >= x.l.line)) {
			block_size += 1;
			buf += x;
		} else {
			// Different file or gap check failed, reset counter stuff and possibly add to ret
			if((buf != {}) && (block_size >= BLOCK_SIZE)) {
				ret += [CF(prev.file, [ e | el <- sort(buf), e := codeline(el.s)[@linelocation=el.l]])];
			}
			block_size = 0;
			buf = {x};
		}
		// Set the previous location.
		prev = x.l;
	}
	
	// Add the current buffer if it is still within constraint boundaries
	if((buf != {}) && (block_size >= BLOCK_SIZE)) {
		ret += [CF(prev.file, [ e | el <- sort(buf), e := codeline(el.s)[@linelocation=el.l]])];
	}

	return ret;
}



/**
 * Match fragments that are identical or similar.
 * @param cl The list containing the code fragments to be matched.
 * @return set[CFxy] A set containing all matching pairs of code fragments
 */
public list[CFxy] matchFragments(list[CF] cl) {

	// also match each fragment with itself to find duplication inside a single CF
	list[list[CFxy]] x = [matchPair(cla, clb) | cla <- cl, clb <- cl];

	// get rid of the duplicate elements
	list[CFxy] ret = [z | y <- x, z <- y, !isIdenticalCF(z.x, z.y)];
			
	// create a map (size : CFxy) to speed up the rest of the computation
	map[int, list[CFxy]] sortedRet = ( );
	list[CFxy] init = [];
	for (z <- ret)
		sortedRet[size(z.x.lines)]?init += [z];

	// remove elements already contained in other elements and mirror elements
	for (s <- sortedRet) 
		for (k <- sortedRet && k < s) 
			for (z <- sortedRet[s])
				for (z1 <- sortedRet[k])
					if (isSubCFxy(z1, z) && !isIdenticalCFxy(z1, z))
						sortedRet[k] -= [z1];
	
	
	list[CFxy] retMirror = [e | s <- sortedRet, e <- sortedRet[s]];	
	ret = [];
	
	for (z <- retMirror) {
		bool found = false;
		for (z1 <- ret && !found)
			if (isMirrorCFxy(z, z1))
				found = true;
		if (!found)
			ret += [z];
	}

	return ret;
}






/**
 * Find any matches within two code fragments
 * @return list[CFxy] all possible matches found (possibly including duplicates)
 *
 * Note: Presumes CF's are already sorted (which currently is the case) -- Kevin
 */
private list[CFxy] matchPair( CF a, CF b) {
	// Some temporary buffer structures
	list[set[int]] bufferA = [{}];
	list[set[int]] bufferB = [{}];
	list[CFxy] ret = [];

	// Do this twice so all annotations are retained.
	intersectionA = a.lines & b.lines;
	intersectionB = b.lines & a.lines;
	
	// Early return to save time.
	if (size(intersectionA) < BLOCK_SIZE) 
		return ret;
	
	// Get all the indexes of items in the above intersection
	indexingA = [x@linelocation.line | x <- intersectionA];
	indexingB = [x@linelocation.line | x <- intersectionB];

	// get all chunks that are within GAP_SIZE
	// and are bigger than BLOCK_SIZE
	bufferA = filterOut(indexingA);
	bufferB = filterOut(indexingB);

	// No remaining buffers means no possible match.		
	if (size(bufferA) == 0 || size(bufferB) == 0)
		return ret;
	
	// Of each remaining buffer, create a list of the remaining lines in them, 
	// based on their location in the original list. 
	sectionsA = [  [getCodelineByLineNumber(a, f) |  f <- sort(toList(x))]  | x <-bufferA];
	sectionsB = [  [getCodelineByLineNumber(b, g) |  g <- sort(toList(y))]  | y <-bufferB];
	
	// This is gruesomely expensive...
	for(x <- sectionsA, 	y <- sectionsB) {
		for ([_*, X*, _*] := x) { 
			for([_*, Y*, _*] := y) {
				if (X == Y && (size(X) >= BLOCK_SIZE)) {
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




// get all chunks that are within GAP_SIZE
// and are bigger than BLOCK_SIZE
list[set[int]] filterOut(list[int] indexing) {
	s = size(indexing);
	list[set[int]] buffer = [{}];
	set[int] buf = {};
	
	for  (i <- [0..s-2]) {
		if (indexing[i+1] - indexing[i] > GAP_SIZE) {  			
			buffer += buf;
			buf = {};
		} else {
			buf += {indexing[i+1], indexing[i]};
		}
	}
	buffer +=  buf;
	
	return	 [ x | x <- buffer, size(x) >= BLOCK_SIZE];
}
