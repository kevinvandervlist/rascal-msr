module advtrack::tests::testCCCS

import advtrack::Datatypes;
import advtrack::util::random;
import advtrack::kevin::Dups;
import advtrack::kevin::Sections;
import advtrack::tests::testGenerator;

import IO;
import List;
import util::ValueUI;


public bool testCCCS() {
    testcccs = generateCCCS();
    testccs = [generateCC(testcccs)];
    //testfiles = [|tmp:///rascal/advtrack/testFiley|];//tmpFile];
    testfiles = [tmpFile];

    //text(testcccs);
    //text(testccs);
    //text(testfiles);

    ccs = getCloneClasses(testfiles);
    //ccs = testccs;
    //text(ccs);
    //return false;
    if(size(ccs) > 1)
        return false;
    
    cccs = getCCCloneSections(ccs[0]);
    //cccs = testcccs;

    b = true;    

    for(testcfcs <- testcccs) {
        testcfxy = testcfcs.cf;
        testcsxy = testcfcs.cs;
        csxy = getCSxyFromCCCSByCFxy(cccs, testcfxy);
        
        for(testcs <- testcsxy.sections) {
            if(size([x | x <- csxy.sections, isIdenticalCS(x, testcs)]) == 0) {
                println("Did not match <testcs>");
                b = false;
                //return false;
            }
        }
    }
    
    return b;
}

public void main() {
    seed(1);
    for(i<-[1..10000]){ println("<i>"); if(!testCCCS()) { break; } }
}