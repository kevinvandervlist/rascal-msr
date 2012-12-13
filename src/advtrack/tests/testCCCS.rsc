module advtrack::tests::testCCCS

import advtrack::Datatypes;
import advtrack::kevin::Dups;
import advtrack::kevin::Sections;
import advtrack::tests::testGenerator;

import IO;
import List;
import util::ValueUI;


public bool testCCCS() {
    testcccs = generateCCCS();
    testccs = [generateCC(testcccs)];
    testfiles = [tmpFile];

    text(testcccs);
    //text(testccs);
    //text(testfiles);

    ccs = getCloneClasses(testfiles);
    //ccs = testccs;
    cccs = getCCCloneSections(ccs[0]);
    //cccs = testcccs;
    text(cccs);

    for(testcfcs <- testcccs) {
        testcfxy = testcfcs.cf;
        testcsxy = testcfcs.cs;
        csxy = getCSxyFromCCCSByCFxy(cccs, testcfxy);
        
        for(testcs <- testcsxy.sections) {
            if(size([x | x <- csxy.sections, isIdenticalCS(x, testcs)]) == 0)
                println("Did not match <testcs>");
                //return false;
        }
    }
    
    return true;
}