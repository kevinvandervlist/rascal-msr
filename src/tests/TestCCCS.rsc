@license{
  Copyright (c) 2013 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Jimi van der Woning - Jimi.vanderWoning@student.uva.nl}
@contributor{Kevin van der Vlist - kevin@kevinvandervlist.nl}
@contributor{Liam Blythe - liam.blythe@student.uva.nl}
@contributor{Vladimir Komsiyski - vkomsiyski@gmail.com}

module tests::TestCCCS

import Datatypes;
import IO;
import List;
import analysis::CloneClasses;
import analysis::Sections;
import tests::TestGenerator;
import util::Random;

// Another off-by-one error, see TestCC.
private bool testCCCS() {
    testcccs = generateCCCS();
    testccs = [generateCC(testcccs)];
    testfiles = [tmpFile];

    ccs = getCloneClasses(testfiles);

    if(size(ccs) > 1) {
      println("ccs \> 1");
      return false;
    }
    
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
