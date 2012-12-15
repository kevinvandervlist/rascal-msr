module advtrack::kevin::Detection::Classes

import advtrack::Datatypes;
import List;
import Set;
import IO;


public list[CC] createCloneClasses(list[CFxy] fragmentPairs) {

    // check for empty set	
	if (size(fragmentPairs) == 0)
		return [];
	

	init = fragmentPairs [0];
	fragmentPairs = tail(fragmentPairs);
		
	list[CC] ret = [CC([init.x, init.y])];
		

	// for each pair test if it fits in a exising class, otherwise add a new class
	for (fp <- fragmentPairs) {
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
		ret[i] = CC( [ fromComp(x) | x <- dup( [ toComp(y) |  y <- ret[i].fragments])]);
	
	println("sizes of the classes:");
	for (c <- ret) 
		println(size(c.fragments));

	return ret;
}
