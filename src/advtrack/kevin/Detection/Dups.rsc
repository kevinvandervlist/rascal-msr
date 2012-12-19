module advtrack::kevin::Detection::Dups

import List;
import Map;
import Set;
import String;

import resource::versions::Versions;
import resource::versions::git::Git;

import advtrack::Constants;
import advtrack::Datatypes;
import advtrack::kevin::Detection::Classes;
import advtrack::kevin::Detection::Fragments;
import advtrack::kevin::Detection::Sections;
import advtrack::kevin::Filenames;
import advtrack::kevin::Git;
import advtrack::kevin::Util;
import advtrack::kevin::lexer::Lexer;

import DateTime;
import IO;
import util::ValueUI;

//str gitLoc = "/home/vladokom/workspace/uva/HelloWorldGitDemo/";
//str gitLoc  = "/home/vladokom/workspace/uva/Yapo/";
//str gitLoc  = "/home/vladokom/workspace/uva/copy-rascal-msr/";
str gitLoc  = "/home/vladokom/workspace/uva/argouml/";
//str gitLoc  = "/home/jimi/Downloads/yapo/";

//str gitLoc = "/home/kevin/src/HelloWorldGitDemo/";
//str gitLoc = "/home/kevin/src/CHelloWorldGitDemo/";
//str gitLoc = "/home/kevin/src/argouml/";
//str gitLoc = "/home/kevin/src/yapo/";
//str gitLoc = "/home/kevin/src/rascal-msr-copy/";

/**
 * Create a map (str line: {location}) where each line of each file is used as a key.
 * NOTE: / TODO: Whitespace and/or comments is not ignored because of speed issues.
 * @param files: A list of file loc s.
 * @return dupdict A map[str line, set[location] locs];
 */

private dupdict createLineMap(list[loc] files) {
	/*
	 * Lex files to rewrite identifiers and remove comments and 
	 * leading / trailing / intermediate whitespace.
	 * The lexer is able to detect if and how to lex a file.
	 */
		
	// Rascal apparantly has a bug with filenames with curlys in them. 
	// Or something in combination with git. Add exists() for now.
	
	rel_ = { <l[i], location(file, i)> | file <- files, 
										 exists(file), 
										 l := lexFile(file), 
										 i <- [0..size(l) - 1] };
		
	return toMap(rel_);
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
 
 	start_ = now();
 	// Create a map with all duplicate occurences.
	dup_occurences = createLineMap(fileList);
	println("createLineMap <now() - start_>");
	
	// Filter the strings that occur only once.
	start_ = now();
	occurences = stripSingles(dup_occurences);
	println("stripSingles <now() - start_>");
	
	// Remove whitespace? By doing so, it is blazingly fast.
	start_ = now();
	occurences = removeEmptyLines(occurences);
	println("rmvEmptyLines <now() - start_>");
	
	// Create a list of code fragments for further analysis.
	start_ = now();
	fragments = createCodeFragments(occurences);
	println("createFragments <now() - start_>");
	
	// Match fragments with each other to form clone classes
	start_ = now();
	fragmentPairs = matchFragments(fragments);
	println("matchFragments <now() - start_>");
		
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
	start_ = now();
	cloneClasses = createCloneClasses(fragmentPairs);
	println("createCloneClasses <now() - start_>");
	
	return cloneClasses;
 
}

/**
 * A test to see wether we can do something with history over time...
 */

public list[Generation] getCCCloneSectionsOverTime() {
	list[Generation] generations = [];
	
	con = fs(gitLoc);
	set[LogOption] opt = {reverse()};
	repo = git(con, "", opt);
	cs = getChangesets(repo);
	
	// Get all CheckoutUnits of the current repo:
	revs = getRevisions(cs);
	cu = getCheckoutUnits(revs);
	
	// Limit to last 3 revisions.
	cu = tail(cu, 3);
	
	// Check out all the revisions in succesion...	
	println("Starting analyzing <size(cu)> CheckoutUnits @ <printTime(now(), "HH:mm:ss")>");

	int x = 1;
	for(c <- cu) {
		println("CheckoutUnit <x>...");
		x += 1;
		
		fileList = getFilesFromCheckoutUnit(c, repo);
		
		fileList = getByFileExtension(".java", fileList);
		
		cc = getCloneClasses(fileList);
		println("getCloneClasses() @ <printTime(now(), "HH:mm:ss")>");

		list[CCCloneSections] sec = [];
		
		for (cx <- cc) 
			sec += [getCCCloneSections(cx)];
		
		println("getCCCloneSections() @ <printTime(now(), "HH:mm:ss")>");
		generations += Generation(c, sec);
	}
	// Restore the state to the master branch
	master = cunit(branch("master"));
	checkoutResources(master, repo);
	
	println("Done with <size(generations)> revisions @ <printTime(now(), "HH:mm:ss")>");
	text(generations);
	
	println("Dump written to <GENDUMP_LOC>.");
	writeGenerationsToFile(generations, GENDUMP_LOC);
	return generations;
}

public void main() {
	println("Start @ <printTime(now(), "HH:mm:ss")>");
	start_ = now();
	
	// Create a 'Connection' datatype.
	con = fs(gitLoc);
	
	// Reverse so the oldest revision will be on top
	set[LogOption] opt = {reverse()};
	
	// Create a 'Repository' datatype of the git Connection
	repo = git(con, "", opt);
	
	// Get a list of files:
	m = cunit(branch("master"));
	fileList = getFilesFromCheckoutUnit(m, repo);
	
	// Filter file extensions
	fileList = getByFileExtension(".java", fileList);

	println("Git and file stuff done in <now() - start_>");
	start_ = now();

	cc = getCloneClasses(fileList);
	println("getCloneClasses() done in <now() - start_>");
	//text(cc);
///*	
	start_ = now();
	list[CCCloneSections] sec = [];
	
	for (c <- cc) 
		sec += [getCCCloneSections(c)];
	
	println("getCCCloneSections() done in <now() - start_>");
	//text(sec);//*/
}
