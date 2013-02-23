module advtrack::main

import IO;
import advtrack::kevin::Detection::Dups;
import advtrack::util::Files;
import advtrack::vis::Classes;

private loc source = |file:///home/kevin/src/QL-R-kemi/src/|;

public void main() {
	fileList = listFilesRecursively(source);
	fileList = getByFileExtension(".rsc", fileList);
	ccs = getCloneClasses(fileList);
	visualizeCloneClasses(ccs);
}
