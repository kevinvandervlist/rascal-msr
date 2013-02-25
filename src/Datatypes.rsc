@license{
  Copyright (c) 2013 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Jimi van der Woning - Jimi.vanderWoning@student.uva.nl}
@contributor{Kevin van der Vlist - kevin@kevinvandervlist.nl}
@contributor{Liam Blythe - liam.blythe@student.uva.nl}
@contributor{Vladimir Komsiyski - vkomsiyski@gmail.com}

module Datatypes

import IO;
import List;
import Set;

// location of a line from a source file
data location = location(loc file, int line);

// A line of code and the location
// The file location will be an annotation, because it will be very 
// easy to compare CFs that way.
data codeline = codeline(str line);
anno location codeline @ linelocation;

// codeline representation without the annotation for ease of comparison
data codelineComp = codelineComp(str line, location linelocation);

// Clone Fragment CF is a set of a codelines and their location
// The file location will be an annotation, because it will be very 
// easy to compare CFs that way.
data CF = CF(loc file, list[codeline] lines);

// Code Fragment representation with the alternative codeline
data CFComp = CFComp(loc file, list[codelineComp] lines);

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

//a file
data File = File(loc filelocation, list[str] lines);

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
	return a.lines == b.lines;
}


public list[CF] CFsWithLoc(loc l, list[CC] ccs) =
	[cf | cc <- ccs, cf <- cc.fragments, cf.file == l];


public CC getCC(CF cf, list[CC] ccs) {
	for(cc <- ccs){ for(fragment <- cc.fragments) { if(cf == fragment) { return cc; } } }
}


public bool isEqualLineLocation(location a, location b){
	return a.file == b.file && a.line == b.line;
}


public bool isIdenticalCFxy(CFxy a, CFxy b) =
    isIdenticalCF(a.x, b.x) && isIdenticalCF(a.y, b.y);


public bool isIdenticalCF(CF a, CF b) =
	isIdenticalCodelines(a.lines, b.lines);

public bool isIdenticalCS(CS a, CS b) =
    isIdenticalCodeblock(a.x, b.x) && isIdenticalCodeblock(a.y, b.y);

public bool isIdenticalCodeblock(codeblock a, codeblock b) =
    isIdenticalCodelines(a.lines, b.lines);

public bool isIdenticalCodelines(list[codeline] a, list[codeline] b) {
    if(size(a) != size(b)) return false;

    cmp = zip(a, b);
    for(<l, r> <- cmp) {
        if(l.line != r.line || !isEqualLineLocation(l@linelocation, r@linelocation) ) {
            return false;
        }
    }
    return true;
}

// huh? Jimi, was that you?
public CSxy getCSxyFromCCCSByCFxy(CCCloneSections cccs, CFxy cf) {
    for(cfcs <- cccs) {
        if(isIdenticalCFxy(cfcs.cf, cf)) return cfcs.cs;
    }
    return CSxy({});
}

public bool isMirrorCFxy(CFxy a, CFxy b) {
	return (isIdenticalCF(a.x, b.y) && isIdenticalCF(a.y, b.x));
}


public bool isIdenticalCFxy(CFxy a, CFxy b) {
	return (isIdenticalCF(a.x, b.x) && isIdenticalCF(a.y, b.y));
}



public bool isSubCFxy(CFxy a, CFxy b) {
	if (!((isSubCF(a.x, b.x) && isSubCF(a.y, b.y)) ||
			(isSubCF(a.y, b.x) && isSubCF(a.x, b.y)))) 
		return false;
	
	axComp = toComp(a.x);
	ayComp = toComp(a.y);
	bxComp = toComp(b.x);
	byComp = toComp(b.y);
	
	return ((isSubCFComp(axComp, bxComp) && isSubCFComp(ayComp, byComp)) || 
			(isSubCFComp(ayComp, bxComp) && isSubCFComp(axComp, byComp))); 
}


public bool isSubCF(CF a, CF b) {
	return a.lines <= b.lines;
}


//check if a is a subfragment of b 
public bool isSubCFComp(CFComp a, CFComp b) {
	return a.lines <= b.lines;
}


public codelineComp toComp(codeline c) {
	return codelineComp(c.line, c@linelocation);
}

public CFComp toComp(CF c) {
	return CFComp(c.file, [toComp(z) | z <- c.lines]);
}

public CF fromComp(CFComp c) {
	return CF(c.file, [fromComp(l) | l <- c.lines]);
}

public codeline fromComp(codelineComp c) {
	return codeline(c.line)[@linelocation = c.linelocation];
}

public str toStr(CF cf) {
    lines = readFileLines(cf.file);
    return intercalate(
        "\n",
        [
            "<l @ linelocation.line>: <lines[l @ linelocation.line]>" |
            l <- cf.lines
        ]
    );
}

public bool hasFragments(loc l, CC cc) {
    for(cf <- cc.fragments)
        if(cf.file == l)
            return true;

    return false;
}

