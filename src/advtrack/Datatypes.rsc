module advtrack::Datatypes

// location of a line from a source file
data location = location(loc file, int line);

// A line of code and the location
data codeline = codeline(str line, location linelocation);

// Clone Fragment CF is a set of a codelines and their location
data CF = CF(loc file, list[codeline] lines);

// Clone Class CC is a list of CFs
data CC = CC(list[CF] fragments);

// ?
data CFxy = CFxy(CF x, CF y);

// ?
data codeblock = codeblock(list[codeline] lines, int begin);

// ?
data CS = CS(codeblock x, codeblock y);

// ?
data CSxy = CSxy(set[CS] sections);

// ?
data CCCloneSections = CCCloneSections(map[CFxy fragments, CSxy sections] cccs);

alias dupdict = map[str line, set[location] locs];
