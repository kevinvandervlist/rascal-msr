module advtrack::main

import resource::versions::Versions;
import resource::versions::git::Git;

import IO;


/*
General process outline steps:
1. Gapped clone detection
2. Clone section detection on each clone class

Step 1: 
Input: a set of files to be processed for gapped clones. (Set[File])
Ouput: a set of clone classes (Set[CC])
Description: Given a set of files, Gapped clone detection should detect all clone classes present across the files. 
			 A clone class consists of a set of clone fragments. 
			 
Step 2: 
Input: Clone Class (CC)
Output: All clone sections in the clone class (CCCloneSections)
Description: Given a clone class, Step 2 pairs each clone fragment within that clone class and 
			 determines for that pair the set of clone sections. 
			 Step 2 returns all the sets of clone sections found for all pairs of clone fragments.
			 Step 2 is performed for each clone class identified in Step 1.
*/



public void main() {
	println("Hi");
}


