module tests::TestCCCS

import Datatypes;
import IO;
import List;
import analysis::CloneClasses;
import analysis::Sections;
import tests::TestGenerator;
import util::Random;

private bool testCCCS() {
    testcccs = generateCCCS();
    testccs = [generateCC(testcccs)];
    testfiles = [tmpFile];

    ccs = getCloneClasses(testfiles);

    if(size(ccs) > 1)
        return false;
    
    cccs = getCCCloneSections(ccs[0]);

    b = true;    

    for(testcfcs <- testcccs) {
        testcfxy = testcfcs.cf;
        testcsxy = testcfcs.cs;
        csxy = getCSxyFromCCCSByCFxy(cccs, testcfxy);
        
        for(testcs <- testcsxy.sections) {
            if(size([x | x <- csxy.sections, isIdenticalCS(x, testcs)]) == 0) {
                println("Did not match <testcs>");
                b = false;
            }
        }
    }
    
    return b;
}

public test bool testCCCSLoop() {
    seed(1);
    for(i<-[1..100]) { 
        if(!testCCCS()) { 
          return false; 
        } 
    }
    return true;
}
