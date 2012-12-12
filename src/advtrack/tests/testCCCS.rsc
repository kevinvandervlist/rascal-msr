module advtrack::tests::testCCCS

import advtrack::Datatypes;
import advtrack::tests::testGenerator;

import IO;
import List;
import util::ValueUI;


public bool testCCCS() {
    testcccs = generateCCCS();
    testccs = [generateCC(testcccs)];
    testfiles = [tmpFile];

    //text(testcccs);
    //text(testccs);
    //text(testfiles);

    //ccs = getCloneClasses(testfiles);
    ccs = testccs;
    //cccs = getCCCloneSections(ccs[0]);
    cccs = testcccs;

    for(testcfcs <- testcccs) {
        testcfxy = testcfcs.cf;
        testcsxy = testcfcs.cs;
        csxy = getCSxyFromCCCSByCFxy(cccs, testcfxy);
        
        for(testcs <- testcsxy.sections) {
            if(size([x | x <- csxy.sections, isIdenticalCS(x, testcs)]) == 0)
                return false;
        }
    }
    
    return true;
}