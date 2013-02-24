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

module tests::TestCC

import Datatypes;
import IO;
import List;
import analysis::CloneClasses;
import tests::TestGenerator;

// Note: Something broke with the upgrade of rascal to 0.6.0. It probably
// has to do with ranges ([0..1] in 0.5.4 == [0..2] in 0.6.0). The tests fail 
// now, because the testccs is missing one CC. 

public test bool testCC() {
  testcccs = generateCCCS();
  testccs = [generateCC(testcccs)];
  testfiles = [tmpFile];
   ccs = getCloneClasses(testfiles);
    
  for(testcf <- testccs[0].fragments) {
    if(size([x | x <- ccs[0].fragments, isIdenticalCF(x, testcf)]) == 0) {
      return false;
    }
  }
    
  return true;
}
