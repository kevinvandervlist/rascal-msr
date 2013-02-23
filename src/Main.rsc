module Main

import IO;
import analysis::CloneClasses;
import util::Files;
import vis::Classes;

private loc source = |file:///home/kevin/src/QL-R-kemi/src/|;

public void main() {
	fileList = listFilesRecursively(source);
	fileList = getByFileExtension(".rsc", fileList);
	ccs = getCloneClasses(fileList);
	visualizeCloneClasses(ccs);
}
