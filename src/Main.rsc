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
