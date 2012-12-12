module advtrack::kevin::Classes

import advtrack::Datatypes;
import List;
import Set;
import IO;

public list[CC] createCloneClasses(set[CFxy] fragmentPairs) {

    // check for empty set	
	if (size(fragmentPairs) == 0)
		return [];
	
	println("All fragments: <size(fragmentPairs)*2>");

	// non-empty set, take one element to initialize the CC list
	fragmentPairList = toList(fragmentPairs);

	init = fragmentPairList [0];
	fragmentPairList = tail(fragmentPairList);
		
	list[CC] ret = [CC([init.x, init.y])];
		

	// for each pair test if it fits in a exising class, otherwise add a new class
	for (fp <- fragmentPairList) {
		found = false;
		s = size(ret)-1;
		for (i <- [0..s] && !found) {
		appendToFile(|tmp:///log|, "checking class no <i>\n");
			if (isEqualCF(ret[i].fragments[0], fp.x)) {
				appendToFile(|tmp:///log|, "found match\n");
				ret[i].fragments += [fp.x, fp.y];
				found = true;
			}
		}
		if (!found) {
			appendToFile(|tmp:///log|, "no match found\n");
			ret += [CC([fp.x, fp.y])];
		}
	}




	// remove identical elements within a class
	s = size(ret)-1;
	for (i <- [0..s]) 
		ret[i] = CC( [ fromComp(x) | x <- dup( [ toComp(y) |  y <- ret[i].fragments])]);
	
	println("sizes of the classes:");
	for (c <- ret) 
		println(size(c.fragments));

	return ret;
}
