module advtrack::Datatypes


// location of a line from a source file
data location = location(loc file, int line);

// A line of code and the location
data codeline = codeline(str line, location linelocation);

// Clone Fragment CF is a set of a codelines and their location
data CF = CF(loc file, list[codeline] lines);

// Clone Class CC is a list of CFs
data CC = CC(list[CF] fragments);

// a codeblock is a number of consecutive codelines in a clone fragment (CF).
// Example: given CF with codelines [1,2,3,6,7], [1,2,3] and [6,7] are considered codeblocks
data codeblock = codeblock(list[codeline] lines, int begin);

// A clone section consists of two cloned codeblocks. 
// codeblock x is a codeblock from clone fragment x (CF)
// codeblock y is a codeblock from clone fragment y (CF)
data CS = CS(codeblock x, codeblock y);

//A set of clone sections for a clone fragment pair x and y
data CSxy = CSxy(set[CS] sections);

//Pair of clone fragments within a given clone class (CC)
data CFxy = CFxy(CF x, CF y);

// Output from the clone section detection process
// Mapping of clone fragment pairs to their corresponding set of clone sections.
data CCCloneSections = CCCloneSections(map[CFxy fragments, CSxy sections] cccs);
