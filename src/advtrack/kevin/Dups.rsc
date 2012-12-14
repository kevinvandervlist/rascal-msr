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
import advtrack::kevin::Sections;
import advtrack::kevin::Filenames;
import advtrack::kevin::Git;
import advtrack::kevin::lexer::Lexer;
import advtrack::Constants;

import IO;
import util::ValueUI;

//str gitLoc = "/home/vladokom/workspace/uva/HelloWorldGitDemo/";
str gitLoc = "/home/kevin/src/HelloWorldGitDemo/";
//str gitLoc = "/home/kevin/src/CHelloWorldGitDemo/";

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
		/*
		 * Lex files to rewrite identifiers and remove comments and 
		 * leading / trailing / intermediate whitespace.
		 * The lexer is able to detect if and how to lex a file.
		 */
		lineList = lexFile(file);
		//println("File: <file>, size: <size(lineList)>");
		//for( l <- lineList) {
		//	println(l);
		//}
    	
		int count = 0;
		for(line <- lineList) {
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
 * All the lines from the map that only consist of an empty line
 */

private dupdict removeEmptyLines(dupdict dict) {
	return (key : dict[key] | key <- dict, key != "");
}

/**
 * Test main stuff.
 */
 public list[CC] getCloneClasses(list[loc] fileList) {
 
 	// Create a map with all duplicate occurences.
	dup_occurences = createLineMap(fileList);
	
	// Filter the strings that occur only once.
	occurences = stripSingles(dup_occurences);
	
	// Remove whitespace? By doing so, it is blazingly fast.
	occurences = removeEmptyLines(dup_occurences);

	// Create a list of code fragments for further analysis.
	fragments = createCodeFragments(occurences);
	
	// Match fragments with each other to form clone classes
	fragmentPairs = matchFragments(fragments);
		
	/*
	for (fp <- fragmentPairs) {
		fx = fp.x.file; 
		lx = fp.x.lines;
		fy = fp.y.file; 
		ly = fp.y.lines;
		println("<fx> at <head(lx)@linelocation.line> to <last(lx)@linelocation.line>");
		println("<fy> at <head(ly)@linelocation.line> to <last(ly)@linelocation.line>");
		println(" ");
	}
	*/
	
	// Create the clone classes from the mathed pairs
	cloneClasses = createCloneClasses(fragmentPairs);
	
	return cloneClasses;
 
 }
 
 
 

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
	
	fileList = removeByFileExtension(".class", fileList);
	//fileList = getByFileExtension(".java", fileList);
	
	cc = getCloneClasses(fileList);
	
	list[CCCloneSections] sec = [];
	
	for (c <- cc) 
		sec += [getCCCloneSections(c)];
	
	text(sec);
}
