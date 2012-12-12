module advtrack::tests::testCC

import advtrack::Datatypes;
import advtrack::kevin::Dups;
import advtrack::tests::testGenerator;

import IO;
import List;
import util::ValueUI;


public bool testCC() {
    testcccs = generateCCCS();
    testccs = [generateCC(testcccs)];
    testfiles = [tmpFile];

    ccs = getCloneClasses(testfiles);
    //ccs = testccs;
    for(testcf <- testccs[0].fragments) {
        if(size([x | x <- ccs[0].fragments, isIdenticalCF(x, testcf)]) == 0)
            println("Did not find <testcf>");
            //return false;
    }
    
    return true;
}