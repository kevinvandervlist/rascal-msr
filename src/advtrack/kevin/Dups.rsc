module advtrack::kevin::Dups

import List;
import Map;
import Set;
import String;

import resource::versions::Versions;
import resource::versions::git::Git;

import advtrack::Datatypes;
import advtrack::kevin::Fragments;
import advtrack::kevin::Classes;
import advtrack::kevin::Filenames;
import advtrack::kevin::Git;
import advtrack::kevin::lexer::Lexer;
import advtrack::Constants;

import IO;
import util::ValueUI;

str gitLoc = "/home/vladokom/workspace/uva/HelloWorldGitDemo/";
//str gitLoc = "/home/kevin/src/HelloWorldGitDemo/";

/**
 * Create a map (str line: {location}) where each line of each file is used as a key.
 * NOTE: / TODO: Whitespace and/or comments is not ignored because of speed issues.
 * @param files: A list of file loc s.
 * @return dupdict A map[str line, set[location] locs];
 */

private dupdict createLineMap(list[loc] files) {
	dupdict ret = ();
	
	// Needed, see issue 32: https://github.com/cwi-swat/rascal/issues/32
	set[location] init = {};
	
	for(file <- files) {
		lineList = readFileLines(file);
		  // Normalize line breaks
  	 //	 linesString = replaceAll(linesString, "\r", "\n");
    
    	// Remove all comments and leading spaces
    //	while (/<x:\/\*.*?\*\/\s*|\/{2}.*?\s*?\n|\n\s+?>/s := linesString)
     //   	linesString = replaceFirst(linesString, x, "\n");
    
    	// Remove all empty lines and closing curly braces
    //	lineList = split("\n", linesString);
    //	lineList = lineList - [x | x <- lineList, /^\s*\}*\s*$/ := x];	
    	
		int count = 0;

		for(line <- lineList) {
			//lineLex = lexLine(line);
			ret[line]?init += { location(file, count) };
			count += 1;
		}
	}

	return ret;
}

/**
 * Filter the map of all occurences that are found only once.
 * @param d A dupdict: {location}
 * @return dupdict A map[str line, set[location] locs];
 */

private dupdict stripSingles(dupdict dict) {
	return (key : dict[key] | key <- dict, size(dict[key]) > 1);
}

/**
 * Test main stuff.
 */

public void main() {

	// Create a 'Connection' datatype.
	con = fs(gitLoc);
	
	// Reverse so the oldest revision will be on top
	set[LogOption] opt = {reverse()};
	
	// Create a 'Repository' datatype of the git Connection
	repo = git(con, "", opt);
	
	// Get a list of files:
	m = cunit(branch("master"));
	fileList = getFilesFromCheckoutUnit(m, repo);
	
	// Remove files that end with a class extension
	fileList = stripFileExtension(".class", fileList);
	
	// Create a map with all duplicate occurences.
	dup_occurences = createLineMap(fileList);
	
	// Filter the strings that occur only once.
	occurences = stripSingles(dup_occurences);

	// Create a list of code fragments for further analysis.
	fragments = createCodeFragments(occurences);
	
	// Match fragments with each other to form clone classes
	fragmentPairs = matchFragments(fragments);
	
	println(size(fragmentPairs)); 
	
	for (fp <- fragmentPairs) {
		fx = fp.x.file; 
		lx = fp.x.lines;
		fy = fp.y.file; 
		ly = fp.y.lines;
		println("<fx> at <head(lx)@linelocation.line> to <last(lx)@linelocation.line>");
		println("<fy> at <head(ly)@linelocation.line> to <last(ly)@linelocation.line>");
		println(" ");
	}
	
	
	// Create the clone classes from the mathed pairs
	cloneClasses = createCloneClasses(fragmentPairs);
	
	text(cloneClasses);

}
