module analysis::CloneClasses

import Constants;
import Datatypes;
import IO;
import List;
import Map;
import Set;
import String;
import analysis::Fragments;
import analysis::Sections;
import lexer::Lexer;
import util::Files;

/**
 * Create a map (str line: {location}) where each line of each file is used as a key.
 * NOTE: / TODO: Whitespace and/or comments is not ignored because of speed issues.
 * @param files: A list of file loc s.
 * @return dupdict A map[str line, set[location] locs];
 */

private dupdict createLineMap(list[loc] files) =
  toMap({
    <l[i], location(file, i)> | 
    file <- files, 
    exists(file), 
    l := lexFile(file),
    len := size(l),
    len > 0,
    i <- [0..len - 1]}
  );
  
private list[CC] createCloneClasses(list[CFxy] fragmentPairs) =
  [] 
    when size(fragmentPairs) == 0;

private default list[CC] createCloneClasses(list[CFxy] fragmentPairs) {

  <first, pairs> = headTail(fragmentPairs);
		
	list[CC] ret = [CC([first.x, first.y])];

	// for each pair test if it fits in a exising class, otherwise add a new class
	for (fp <- pairs) {
		found = false;
		s = size(ret)-1;
		for (i <- [0..s] && !found) {
			if (isEqualCF(ret[i].fragments[0], fp.x)) {
				ret[i].fragments += [fp.x, fp.y];
				found = true;
			}
		}
		if (!found) {
			ret += [CC([fp.x, fp.y])];
		}
	}

	// remove identical elements within a class
	s = size(ret)-1;
	for (i <- [0..s]) 
		ret[i] = CC([ fromComp(x) | x <- dup( [ toComp(y) |  y <- ret[i].fragments])]);

	return ret;
}

private dupdict stripUniques(dupdict dict) = 
	(key : dict[key] | key <- dict, size(dict[key]) > 1);

private dupdict removeEmptyLines(dupdict dict) = 
  (key : dict[key] | key <- dict, key != "");

public list[CC] getCloneClasses(list[loc] fileList) {
 	// Create a map with all duplicate occurences.
	dup_occurences = createLineMap(fileList);
	// Filter the strings that occur only once.
	occurences = stripUniques(dup_occurences);
	// Remove whitespace? By doing so, it is blazingly fast.
	occurences = removeEmptyLines(occurences);
	// Create a list of code fragments for further analysis.
	fragments = createCodeFragments(occurences);
	// Match fragments with each other to form clone classes
	fragmentPairs = matchFragments(fragments);
	// Create the clone classes from the mathed pairs
	cloneClasses = createCloneClasses(fragmentPairs);
	return cloneClasses;
}
