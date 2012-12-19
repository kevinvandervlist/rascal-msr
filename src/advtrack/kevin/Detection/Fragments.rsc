module advtrack::kevin::Detection::Fragments

import List;
import Set;
import util::Math;
import util::ValueUI;

import DateTime;

import advtrack::kevin::Detection::Dups;
import advtrack::Datatypes;
import advtrack::Constants;

import IO;
import ValueIO;

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
	
	// Does the list contain elements at all?
	if(lst == []) 
		return ret;
	
	// Set the current file
	location prev = head(lst).l;
	int block_size = 0;
		
	for(x <- lst) {
		// Same file, in block threshold?
		if(	(x.l.file == prev.file) &&
			((prev.line + GAP_SIZE + 1) >= x.l.line)) {
			block_size += 1;
			buf += x;
		} else {
			// Different file or gap check failed, reset counter stuff and possibly add to ret
			if((buf != {}) && (block_size >= BLOCK_SIZE)) {
				ret += [CF(prev.file, [ e | el <- sort(buf), e := codeline(el.s)[@linelocation=el.l]])];
			}
			block_size = 1;
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
	return [z | y <- [matchPair(cla, clb) | cla <- cl, clb <- cl], z <- y];
	
	/*
	count = 0;
	for (cla <- cl, clb <- cl) {
		x = matchPair(cla, clb);
		if (size(x) > 0) {
			writeBinaryValueFile(|tmp:///pairs| + "<count>", x);
			count += 1;
		}
	}	
	return [];*/
		
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

	// Do this twice so all annotations are retained.
	intersectionA = a.lines & b.lines;
	intersectionB = b.lines & a.lines;
	
	// Early return to save time.
	if (size(intersectionA) < BLOCK_SIZE) 
		return [];
	
	// Get all the indexes of items in the above intersection
	indexingA = [x@linelocation.line | x <- intersectionA];
	indexingB = [x@linelocation.line | x <- intersectionB];

	// get all chunks that are within GAP_SIZE
	// and are bigger than BLOCK_SIZE
	bufferA = filterOut(indexingA);
	bufferB = filterOut(indexingB);

	// No remaining buffers means no possible match.		
	if (size(bufferA) == 0 || size(bufferB) == 0)
		return [];
	
	// Of each remaining buffer, create a list of the remaining lines in them, 
	// based on their location in the original list. 
	sectionsA = [  [getCodelineByLineNumber(a, f) |  f <- sort(toList(x))]  | x <-bufferA];
	sectionsB = [  [getCodelineByLineNumber(b, g) |  g <- sort(toList(y))]  | y <-bufferB];
	
	// This is gruesomely expensive...
	// NOTE: Use regular expression functionality in list pattern matching
	subX = [X | x <- sectionsA, [_*, X*, _*] := x, size(X) >= BLOCK_SIZE];
	subY = [X | y <- sectionsB, [_*, X*, _*] := y, size(X) >= BLOCK_SIZE];
	commonX = subX & subY;
	commonY = subY & subX;
	
	subCommonX = (lineloc : [s | s <- commonX, head(s)@linelocation == lineloc ] | [h,t*] <- commonX, lineloc := h@linelocation);
	commonX = [head(sort(subCommonX[k], bool(list[codeline] a, list[codeline] b){ return size(a) >= size(b); })) | k <- subCommonX];
		
	subCommonY = (lineloc : [s | s <- commonY, head(s)@linelocation == lineloc ] | [h,t*] <- commonY, lineloc := h@linelocation);
	commonY = [head(sort(subCommonY[k], bool(list[codeline] a, list[codeline] b){ return size(a) >= size(b); })) | k <- subCommonY];
	
	commonX = [ x | x <- commonX, !largerExists(x, commonX)];
	commonY = [ x | x <- commonY, !largerExists(x, commonY)];
	
	return [CFxy(CF(head(X)@linelocation.file, X), 
				 CF(head(Y)@linelocation.file, Y)) | X <- commonX,
													 Y <- commonY,
													 isEqual(X, Y) ];			
}


private bool isEqual(list[codeline] x, list[codeline] y) {
	return (x == y && head(x)@linelocation != head(y)@linelocation);
}



private bool largerExists(list[codeline] x, list[list[codeline]] l) {
	for (k <- l) {
		if (k > x) {
			if (head(k)@linelocation.line < head(x)@linelocation.line &&
				last(k)@linelocation.line > last(x)@linelocation.line)
				return true;	
		}
	}	
	return false;
}

private codeline getCodelineByLineNumber(CF x, int l) {
	return head([t | t <- x.lines, t@linelocation.line == l]);
}

// get all chunks that are within GAP_SIZE
// and are bigger than BLOCK_SIZE
list[set[int]] filterOut(list[int] indexing) {
	s = size(indexing);
	list[set[int]] buffer = [{}];
	set[int] buf = {};
	
	// Can't be done if the list is < BLOCK_SIZE anyway, so just return
	if(s < BLOCK_SIZE) {
		return buffer;
	}
	
	for  (i <- [0..s-2]) {
		if (indexing[i+1] - indexing[i] - 1 > GAP_SIZE) {  			
			buffer += buf;
			buf = {};
		} else {
			buf += {indexing[i+1], indexing[i]};
		}
	}
	buffer +=  buf;
	
	return	 [ x | x <- buffer, size(x) >= BLOCK_SIZE];
}
