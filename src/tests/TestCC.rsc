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
