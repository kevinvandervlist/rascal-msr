module advtrack::Datatypes

import List;

// location of a line from a source file
data location = location(loc file, int line);

// A line of code and the location
// The file location will be an annotation, because it will be very 
// easy to compare CFs that way.
data codeline = codeline(str line);
anno location codeline @ linelocation;

// Clone Fragment CF is a set of a codelines and their location
// The file location will be an annotation, because it will be very 
// easy to compare CFs that way.
data CF = CF(loc file, list[codeline] lines);

// Clone Class CC is a list of CFs
data CC = CC(list[CF] fragments);

// a codeblock is a number of consecutive codelines in a clone fragment (CF).
// Example: given CF with codelines [1,2,3,6,7], then [1,2,3] and [6,7] are considered codeblocks
data codeblock = codeblock(list[codeline] lines, int begin);

// A clone section consists of two cloned codeblocks. 
// codeblock x is a codeblock from clone fragment x (CF)
// codeblock y is a codeblock from clone fragment y (CF)
data CS = CS(codeblock x, codeblock y);

//A set of clone sections for a clone fragment pair x and y
data CSxy = CSxy(set[CS] sections);

//Pair of clone fragments within a given clone class (CC)
data CFxy = CFxy(CF x, CF y);

//Pair of pair of Clone Fragments (CFxy) and their clone sections (CSxy)
data CFxyCSxy = CFxyCSxy(CFxy cf, CSxy cs);

// Mapping of clone fragment pairs to their corresponding set of clone sections.
alias CCCloneSections = list[CFxyCSxy sections];

/**
 * Are two CFs equal?
 * Note: This compares the lines, not the codes. 
 * So, having CF a in file x, and CF b in file Y can be equal 
 * if all the lines are equal. 
 * @param a The first CF
 * @param b The second CF
 * @return Equal or not.
 */

public bool isEqualCF(CF a, CF b) {
	cla = a.lines;
	clb = b.lines;
	
	// Are they of the same length?
	if(size(cla) != size(clb)) {
		return false;
	}
	
	// Compare all the elements.
	cmp = zip(cla, clb);
	for(<l, r> <- cmp) {
		if(l.line != r.line) {
			return false;
		}
	}
	return true;
}


public bool isEqualLineLocation(location a, location b){
	return a.file == b.file && a.line == b.line;
}


public bool isIdenticalCF(CF a, CF b){

	if(size(a.lines) != size(b.lines)) {
		return false;
	}
	
	// Compare all the elements.
	cmp = zip(a.lines, b.lines);
	for(<l, r> <- cmp) {
		if(l.line != r.line || !isEqualLineLocation(l@linelocation, r@linelocation) ) {
			return false;
		}
	}
	return true;
}
