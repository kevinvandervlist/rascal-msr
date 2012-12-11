module advtrack::kevin::Classes

import advtrack::Datatypes;
import List;
import Set;
import IO;

public list[CC] createCloneClasses(set[CFxy] fragmentPairs) {

    // check for empty set	
	if (size(fragmentPairs) == 0)
		return [];

	// non-empty set, take one element to initialize the CC list
	<init, fragmentPairs> = takeOneFrom(fragmentPairs);
	list[CC] ret = [CC([init.x, init.y])];
	ret1 = ret;
		
	// for each pair test if it fits in a exising class, otherwise add a new class
	for (fp <- fragmentPairs) {
		found = false;
		s = size(ret)-1;
		for (i <- [0..s] && !found) {
	//		appendToFile(|tmp:///log|, "checking class no <i>\n");
			if (isEqualCF(ret[i].fragments[0], fp.x)) {
	//			appendToFile(|tmp:///log|, "found match\n");
				ret[i].fragments += [fp.x, fp.y];
				found = true;
				//break;
			}
		}
		if (!found) {
	//		appendToFile(|tmp:///log|, "no match found\n");
			ret += [CC([fp.x, fp.y])];
		}
	}




	for (fp <- fragmentPairs) {
		found = false;
		s = size(ret1)-1;
		for (i <- [0..s]) {
//			appendToFile(|tmp:///log2|, "checking class no <i>\n");
			if (isEqualCF(ret1[i].fragments[0], fp.x)) {
//				appendToFile(|tmp:///log2|, "found match\n");
				ret1[i].fragments += [fp.x, fp.y];
				found = true;
				break;
			}
		}
		if (!found) {
//			appendToFile(|tmp:///log2|, "no match found\n");
			ret1 += [CC([fp.x, fp.y])];
		}
	}




	// remove identical elements within a class
//	s = size(ret)-1;
//	for (i <- [0..s]) 
//		ret[i] = CC( [ fromComp(x) | x <- dup( [ toComp(y) |  y <- ret[i].fragments])]);
	
	
	if (ret == ret1)
		println("equal");
	
	println("sizes of the classes 1:");
	for (c <- ret) 
		println(size(c.fragments));
	
	println("sizes of the classes 2:");
	for (c <- ret1) 
		println(size(c.fragments));

	return ret;
}
