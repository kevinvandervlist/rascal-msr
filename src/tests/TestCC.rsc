module tests::TestCC

import Datatypes;
import IO;
import List;
import analysis::CloneClasses;
import tests::TestGenerator;

public test bool testCC() {
    testcccs = generateCCCS();
    testccs = [generateCC(testcccs)];
    testfiles = [tmpFile];

    ccs = getCloneClasses(testfiles);
    
    for(testcf <- testccs[0].fragments) {
        if(size([x | x <- ccs[0].fragments, isIdenticalCF(x, testcf)]) == 0)
            return false;
    }
    
    return true;
}
