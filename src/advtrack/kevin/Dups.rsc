module advtrack::kevin::Dups

import Set;
import Map;

import resource::versions::Versions;
import resource::versions::git::Git;

import advtrack::kevin::Git;
import advtrack::kevin::Filenames;
import advtrack::Datatypes;

import IO;
import util::ValueUI;

str gitLoc = "/home/kevin/src/HelloWorldGitDemo/";

alias dupdict = map[str line, set[location] locs];

/**
 * Create a map (str line: {location}) where each line of each file is used as a key.
 * NOTE: / TODO: Whitespace and/or comments is not ignored because of speed issues.
 * @param files: A list of file loc s.
 * @return dupdict A map[str line, set[location] locs];
 */

private dupdict createLineMap(list[loc] files) {
	dupdict ret = ();
	for(f <- files) {
		lines = readFileLines(f);
	
		int cnt = 0;
		// TODO: Improve the following lines, it's ugly
		for(l <- lines) {
			t = location(f, cnt);
			if(l in ret) {
				ret[l] = ret[l] + {t};
			} else {
				ret[l] = {t};
			}
			cnt += 1;
		}
	}
	return ret;
}

/**
 * Filter the map of all occurences that are found only once.
 * @param d A dupdict: {location}
 * @return dupdict A map[str line, set[location] locs];
 */

private dupdict stripSingles(dupdict d) {
	return (k : d[k] | k <- d, size(d[k]) > 1);
}

private rel[location, str] createStringLocationList(dupdict dup) {
	rel[location, str] ret = {};
	for(d <- dup) {
		ret += { < x, d> | x <- dup[d] };
	}
	return ret;
}

private void createBlockList(int block, int gap, dupdict dup) {
	l = createStringLocationList(dup);
	text(sort(l));
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
	fl = getFilesFromCheckoutUnit(m, repo);
	
	fl = stripFileExtension(".class", fl);
	
	dup_occurences = createLineMap(fl);
	occurences = stripSingles(dup_occurences);
	//text(occurences);
	createBlockList(6, 3, occurences);
}
