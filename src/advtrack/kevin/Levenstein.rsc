module advtrack::kevin::Levenstein

import String;
import List;
import util::Math;

import IO;

public void main() {
	println("LD: <levensteinDistance("AB", "BC")>");

	str a = "This is a string";
	str b = "this is a string";
	str c = "Today, the weather is nice.";
	println("A :: B -\> <levensteinDistance(a, b)>");
	println("A :: C -\> <levensteinDistance(a, c)>");
	println("B :: C -\> <levensteinDistance(b, c)>");
}

/**
 * Taken from: 
 * https://github.com/dbalatero/levenshtein-ffi/blob/master/ext/levenshtein/levenshtein.c
 */

public int levensteinDistance(str a, str b) {
	if(a == b)
		return 0;
		
	al = chars(a);
	als = size(a);
	
	bl = chars(b);
	bls = size(b);
	
	map[int, int] v = ();
	
	int current = 0; 
	int cost = 0;
	int next;

    // Common prefixes
    int k = 0;
    while (als > 0 && bls > 0 && (al[k] == bl[k])) {
        als-=1; 
        bls-=1; 
        k+=1;
	}
        
	if(als == 0)
		return bls;
	
	if(bls == 0)
		return als;
    
    /* initialize the column vector */
    for(j <- [0..bls]) {
    	v[j] = j;
    }
    
    for(i <- [0..als-1]) {
        /* set the value of the first row */
        current = i + 1;
        /* for each row in the column, compute the cost */
        for(j <- [0..bls-1]) {
            /*
             * cost of replacement is 0 if the two chars are the same, or have
             * been transposed with the chars immediately before. otherwise 1.
             */
            if((al[i] == bl[j]) || (i > 0 && j > 0 && (al[i-1] == bl[j]) && (al[i] == bl[j-1]))) {
            	cost = 0;
            } else {
            	cost = 1;
            }
            /* find the least cost of insertion, deletion, or replacement */
            next = min3(v[j+1] + 1, current + 1, v[j] + cost);
            /* stash the previous row's cost in the column vector */
            v[j] = current;
            /* make the cost of the next transition current */
            current = next;
        }
        /* keep the final cost at the bottom of the column */
        v[bls] = next;
    }
    return next;
}

private int min3(int a, int b, int c) {
	return min(a, min(b, c));
}